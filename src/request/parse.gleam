import gleam/list
import gleam/option
import gleam/result
import gleam/string

import request/request.{type HTTPRequest, type HTTPRequestMethod}

pub type RequestParsingError {
  UnreadableRequestLine
  UnknownMethod
  InvalidHTTPVersion
  UnreadableHeaders
  UnreadableBody
}

const section_marker: String = "\r\n"

fn parse_request_line(
  request_line: String,
) -> Result(#(HTTPRequestMethod, String, String), RequestParsingError) {
  let request_line = request_line |> string.split(" ")

  use method <- result.try(
    request_line
    |> list.first
    |> result.replace_error(UnreadableRequestLine)
    |> result.map(fn(method) {
      method |> request.parse_method |> result.replace_error(UnknownMethod)
    })
    |> result.flatten,
  )

  use route_and_http_version <- result.try(
    request_line
    |> list.rest
    |> result.replace_error(UnreadableRequestLine),
  )

  use route <- result.try(
    route_and_http_version
    |> list.first
    |> result.replace_error(UnreadableRequestLine),
  )

  use http_version <- result.try(
    route_and_http_version
    |> list.rest
    |> result.map(list.first)
    |> result.flatten
    |> result.replace_error(UnreadableRequestLine),
  )

  Ok(#(method, route, http_version))
}

fn parse_header(
  header: String,
) -> Result(#(String, String), RequestParsingError) {
  let header = header |> string.split(":")

  use key <- result.try(
    header |> list.first |> result.replace_error(UnreadableHeaders),
  )

  // Values can contain ":" as well. Just making sure all of the value is included
  use value <- result.try(
    header
    |> list.rest
    |> result.replace_error(UnreadableHeaders)
    |> result.map(fn(rest) { rest |> string.join(":") }),
  )

  Ok(#(key, value))
}

fn parse_headers_recursive(
  source: List(String),
  headers: List(#(String, String)),
) -> Result(List(#(String, String)), RequestParsingError) {
  use current <- result.try(
    source |> list.first |> result.replace_error(UnreadableHeaders),
  )

  case current {
    "" -> Ok(headers)
    header ->
      header
      |> parse_header
      |> result.map(fn(header) {
        source
        |> list.rest
        |> result.replace_error(UnreadableHeaders)
        |> result.map(fn(source) {
          parse_headers_recursive(source, headers |> list.append([header]))
        })
        |> result.flatten
      })
      |> result.flatten
  }
}

fn parse_headers(
  headers: List(String),
) -> Result(List(#(String, String)), RequestParsingError) {
  parse_headers_recursive(headers, list.new())
}

pub fn parse_request(
  request: String,
) -> Result(HTTPRequest, RequestParsingError) {
  let request = request |> string.split(section_marker)
  use #(method, path, http_version) <- result.try(
    request
    |> list.first
    |> result.replace_error(UnreadableRequestLine)
    |> result.map(parse_request_line)
    |> result.flatten,
  )

  use headers <- result.try(
    request
    |> list.rest
    |> result.replace_error(UnreadableHeaders)
    |> result.map(parse_headers)
    |> result.flatten,
  )

  use body <- result.try(
    request |> list.last |> result.replace_error(UnreadableBody),
  )

  let body = case body {
    "" -> option.None
    body -> option.Some(body)
  }

  Ok(request.new(
    method: method,
    headers: headers,
    path: path,
    body: body,
    http_version: http_version,
  ))
}
