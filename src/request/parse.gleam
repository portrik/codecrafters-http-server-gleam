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

fn parse_request_headers(
  _headers: List(String),
) -> Result(List(#(String, String)), RequestParsingError) {
  // TODO: Add Header parsing
  Ok(list.new())
}

pub fn parse_request(
  request: String,
) -> Result(HTTPRequest, RequestParsingError) {
  let request = request |> string.split(section_marker)
  use #(method, path, _http_version) <- result.try(
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
    |> result.map(parse_request_headers)
    |> result.flatten,
  )

  // TODO: Add body handling
  Ok(request.Request(
    method: method,
    headers: headers,
    path: path,
    body: option.None,
  ))
}
