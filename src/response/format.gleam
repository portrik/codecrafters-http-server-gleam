import gleam/int
import gleam/list
import gleam/option
import gleam/string

import response/response.{type HTTPResponse}

const section_marker: String = "\r\n"

pub fn format_response(response: HTTPResponse) -> String {
  let status_line =
    [
      "HTTP/1.1",
      response.status |> response.get_status_code |> int.to_string,
      response.get_status_reason(response.status),
    ]
    |> string.join(" ")

  let headers_line =
    response.headers
    |> list.map(fn(header) { string.join([header.0, header.1], ": ") })
    |> string.join(section_marker)
    |> string.append(section_marker)

  let body =
    case response.body {
      option.Some(content) -> content
      option.None -> ""
    }
    |> string.append(section_marker)

  [status_line, headers_line, body] |> string.join(section_marker)
}
