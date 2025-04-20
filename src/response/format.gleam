import gleam/bit_array
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/string
import gzlib

import request/request.{type HTTPRequest}
import response/response.{type HTTPResponse}

pub type FormattedBody {
  PlainBody(String)
  GZIPBody(BitArray)
}

const section_marker: String = "\r\n"

fn normalize_headers(
  headers: List(#(String, String)),
  body: FormattedBody,
) -> List(#(String, String)) {
  let size_header =
    headers |> list.find(fn(header) { header.0 == "Content-Length" })

  let with_size = case size_header {
    Ok(_) -> headers
    Error(_) -> {
      let body_size =
        case body {
          PlainBody(body) -> body |> string.length
          GZIPBody(body) -> body |> bit_array.byte_size
        }
        |> int.to_string

      headers
      |> list.append([#("Content-Length", body_size)])
    }
  }

  case body {
    PlainBody(_) -> with_size
    GZIPBody(_) -> with_size |> list.append([#("Content-Encoding", "gzip")])
  }
}

fn compress_body(
  request: Option(HTTPRequest),
  body: Option(String),
) -> FormattedBody {
  let compression = case request {
    option.None -> option.None
    option.Some(request) -> request.accepts_encoding
  }

  let content = body |> option.unwrap("")

  case compression {
    option.Some(compression) ->
      case string.contains(compression, "gzip") {
        True -> content |> bit_array.from_string |> gzlib.compress |> GZIPBody
        False -> content |> PlainBody
      }
    _ -> content |> PlainBody
  }
}

pub fn format_response(
  response: HTTPResponse,
  request: Option(HTTPRequest),
) -> String {
  let status_line =
    [
      "HTTP/1.1",
      response.status |> response.get_status_code |> int.to_string,
      response.get_status_reason(response.status),
    ]
    |> string.join(" ")

  let body = compress_body(request, response.body)

  let headers_line =
    response.headers
    |> normalize_headers(body)
    |> list.map(fn(header) { string.join([header.0, header.1], ": ") })
    |> string.join(section_marker)
    |> string.append(section_marker)

  let body = case body {
    PlainBody(body) -> body
    GZIPBody(body) -> body |> bit_array.base64_encode(True)
  }

  [status_line, headers_line, body] |> string.join(section_marker)
}
