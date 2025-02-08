import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/string

import response/response

const section_marker: String = "\r\n"

pub fn format_response(
  status: response.HTTPStatus,
  headers: List(#(String, String)),
  body: Option(String),
) -> String {
  let status_line =
    [
      "HTTP/1.1",
      status |> response.get_status_code |> int.to_string,
      response.get_status_reason(status),
    ]
    |> string.join(" ")

  let headers_line =
    headers
    |> list.map(fn(header) { string.join([header.0, header.1], section_marker) })
    |> string.join(section_marker)

  let body = case body {
    option.Some(content) -> content
    option.None -> ""
  }

  [status_line, headers_line, body] |> string.join(section_marker)
}
