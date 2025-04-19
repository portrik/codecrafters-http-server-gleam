import configuration
import file_streams/file_stream
import filepath
import gleam/bit_array
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

import request/request.{type HTTPRequest}
import response/response.{type HTTPResponse}

type FileError {
  FileNameMissing
  DirectoryArgumentMissing
  DirectoryMissing
}

type ReadError {
  ReadFileError(FileError)
  FileUnreadable
  FileContentMissing
  FileMissing
}

type WriteError {
  WriteFileError(FileError)
  CouldNotOpenFile
  ContentNotProvided
  CouldNotWriteData
}

fn read_file(file_name: String) -> Result(String, ReadError) {
  use directory <- result.try(
    case configuration.load_command_line().file_directory {
      option.None -> Error(ReadFileError(DirectoryArgumentMissing))
      option.Some(directory) -> Ok(directory)
    },
  )

  use stream <- result.try(
    directory
    |> filepath.join(file_name)
    |> file_stream.open_read
    |> result.replace_error(FileMissing),
  )

  use content <- result.try(
    stream
    |> file_stream.read_remaining_bytes
    |> result.map(fn(content) {
      content |> bit_array.to_string |> result.replace_error(FileUnreadable)
    })
    |> result.replace_error(FileUnreadable),
  )

  content
}

pub fn filename(request: HTTPRequest) -> HTTPResponse {
  let segments =
    request.path
    |> string.split("/")
    |> list.filter(fn(segment) { !string.is_empty(segment) })

  let file_content = case segments {
    ["files", file_name] -> read_file(file_name)
    _ -> Error(ReadFileError(FileNameMissing))
  }

  case file_content {
    Ok(file_content) ->
      response.HTTPResponse(
        status: response.OK,
        headers: [
          #("Content-Type", "application/octet-stream"),
          #("Content-Length", file_content |> string.length |> int.to_string),
        ],
        body: option.Some(file_content),
      )

    Error(ReadFileError(FileNameMissing)) ->
      response.HTTPResponse(
        status: response.BadRequest,
        headers: list.new(),
        body: option.None,
      )

    Error(ReadFileError(DirectoryArgumentMissing))
    | Error(ReadFileError(DirectoryMissing))
    | Error(FileUnreadable)
    | Error(FileContentMissing) ->
      response.HTTPResponse(
        status: response.InternalServerError,
        headers: list.new(),
        body: option.None,
      )

    Error(FileMissing) ->
      response.HTTPResponse(
        status: response.NotFound,
        headers: list.new(),
        body: option.None,
      )
  }
}

fn write_file(file_name: String, body: String) -> Result(Nil, WriteError) {
  use directory <- result.try(
    case configuration.load_command_line().file_directory {
      option.None -> Error(WriteFileError(DirectoryArgumentMissing))
      option.Some(directory) -> Ok(directory)
    },
  )

  use stream <- result.try(
    directory
    |> filepath.join(file_name)
    |> file_stream.open_write
    |> result.replace_error(CouldNotOpenFile),
  )

  stream
  |> file_stream.write_bytes(body |> bit_array.from_string)
  |> result.replace_error(CouldNotWriteData)
}

pub fn create_file(request: HTTPRequest) -> HTTPResponse {
  let segments =
    request.path
    |> string.split("/")
    |> list.filter(fn(segment) { !string.is_empty(segment) })

  let file_name = case segments {
    ["files", file_name] -> option.Some(file_name)
    _ -> option.None
  }

  let write_result = case file_name, request.body {
    option.Some(file_name), option.Some(body) -> write_file(file_name, body)
    option.None, option.Some(_) -> Error(WriteFileError(FileNameMissing))
    _, option.None -> Error(ContentNotProvided)
  }

  case write_result {
    Ok(_) ->
      response.HTTPResponse(
        status: response.Created,
        headers: list.new(),
        body: option.None,
      )

    Error(ContentNotProvided) ->
      response.HTTPResponse(
        status: response.BadRequest,
        headers: list.new(),
        body: option.Some("File content not provided"),
      )

    Error(WriteFileError(_))
    | Error(CouldNotOpenFile)
    | Error(CouldNotWriteData) ->
      response.HTTPResponse(
        status: response.InternalServerError,
        headers: list.new(),
        body: option.None,
      )
  }
}
