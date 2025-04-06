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

type FileReadError {
  FileNameMissing
  DirectoryArgumentMissing
  DirectoryMissing
  FileMissing
  FileUnreadable
}

fn read_file(file_name: String) -> Result(String, FileReadError) {
  use directory <- result.try(
    case configuration.load_command_line().file_directory {
      option.None -> Error(DirectoryArgumentMissing)
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
    _ -> Error(FileNameMissing)
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

    Error(FileNameMissing) ->
      response.HTTPResponse(
        status: response.BadRequest,
        headers: list.new(),
        body: option.None,
      )

    Error(DirectoryArgumentMissing)
    | Error(DirectoryMissing)
    | Error(FileUnreadable) ->
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
