import gleam/int
import gleam/list
import gleam/string

import response/response

const section_marker: String = "\r\n"

pub fn format_response(
  status: response.HTTPStatus,
  headers: List(#(String, String)),
  body: String,
) -> String {
  let status_line =
    ["HTTP/1.1", int.to_string(status.code), status.reason]
    |> string.join(" ")

  let headers_line =
    headers
    |> list.map(fn(header) { string.join([header.0, header.1], section_marker) })
    |> string.join(section_marker)

  [status_line, headers_line, body] |> string.join(section_marker)
}
