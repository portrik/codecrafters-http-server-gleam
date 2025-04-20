import gleam/bit_array
import gleam/bytes_tree.{type BytesTree}
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/string

import request/request.{type CompressionScheme}
import response/response.{type HTTPResponse}

@external(erlang, "zlib", "gzip")
fn gzip(data: BitArray) -> BitArray

pub type FormattedBody {
  PlainBody(String)
  GZIPBody(BitArray)
}

const section_marker: String = "\r\n"

fn normalize_headers(
  headers: List(#(String, String)),
  body: FormattedBody,
) -> List(#(String, String)) {
  let body_size =
    case body {
      PlainBody(body) -> body |> string.length
      GZIPBody(body) -> body |> bit_array.byte_size
    }
    |> int.to_string

  let with_size =
    headers
    |> list.append([#("Content-Length", body_size)])

  case body {
    PlainBody(_) -> with_size
    GZIPBody(_) -> with_size |> list.append([#("Content-Encoding", "gzip")])
  }
}

fn get_best_compression(
  compression_options: List(CompressionScheme),
) -> CompressionScheme {
  case compression_options {
    [] -> request.NoCompression
    [compression] -> compression
    options ->
      case list.contains(options, request.GZIP) {
        True -> request.GZIP
        False -> request.NoCompression
      }
  }
}

fn compress_body(
  compression_options: List(CompressionScheme),
  body: Option(String),
) -> FormattedBody {
  let content = body |> option.unwrap("")

  case get_best_compression(compression_options) {
    request.GZIP -> content |> bit_array.from_string |> gzip |> GZIPBody
    request.NoCompression -> content |> PlainBody
  }
}

pub fn format_response(
  response: HTTPResponse,
  compression_options: List(CompressionScheme),
) -> BytesTree {
  let status_line =
    [
      "HTTP/1.1",
      response.status |> response.get_status_code |> int.to_string,
      response.get_status_reason(response.status),
    ]
    |> string.join(" ")

  let body = compress_body(compression_options, response.body)

  let headers_line =
    response.headers
    |> normalize_headers(body)
    |> list.map(fn(header) { string.join([header.0, header.1], ": ") })
    |> string.join(section_marker)
    |> string.append(section_marker)

  status_line
  |> bytes_tree.from_string
  |> bytes_tree.append_string(section_marker)
  |> bytes_tree.append_string(headers_line)
  |> bytes_tree.append_string(section_marker)
  |> fn(tree) {
    case body {
      PlainBody(body) -> bytes_tree.append_string(tree, body)
      GZIPBody(body) -> bytes_tree.append(tree, body)
    }
  }
}
