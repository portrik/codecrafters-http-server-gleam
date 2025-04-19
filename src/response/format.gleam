import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/string

import response/response.{type HTTPResponse}

const section_marker: String = "\r\n"

fn normalize_headers(
  headers: List(#(String, String)),
  body: Option(String),
) -> List(#(String, String)) {
  let size_header =
    headers |> list.find(fn(header) { header.0 == "Content-Length" })

  case size_header {
    Ok(_) -> headers
    Error(_) -> {
      let body_size = case body {
        option.Some(body) -> body |> string.length |> int.to_string
        option.None -> "0"
      }

      headers
      |> list.append([#("Content-Length", body_size)])
    }
  }
}

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
    |> normalize_headers(response.body)
    |> list.map(fn(header) { string.join([header.0, header.1], ": ") })
    |> string.join(section_marker)
    |> string.append(section_marker)

  let body = case response.body {
    option.Some(content) -> content
    option.None -> ""
  }

  [status_line, headers_line, body] |> string.join(section_marker)
}
