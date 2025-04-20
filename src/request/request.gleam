import gleam/list
import gleam/option.{type Option}
import gleam/string

pub type HTTPRequestMethod {
  GET
  POST
  PUT
  DELETE

  HEAD
  CONNECT
  OPTIONS
  TRACE
  PATCH
}

pub type CompressionScheme {
  NoCompression
  GZIP
}

pub type UnknownHTTPRequestMethod {
  UnknownHTTPRequestMethod
}

pub type HTTPRequest {
  HTTPRequest(
    method: HTTPRequestMethod,
    headers: List(#(String, String)),
    path: String,
    body: Option(String),
    http_version: String,
    accepts_encodings: List(CompressionScheme),
  )
}

fn compression_scheme_from_string(value: String) -> CompressionScheme {
  case value {
    "" -> NoCompression
    compression ->
      case string.contains(compression, "gzip") {
        True -> GZIP
        False -> NoCompression
      }
  }
}

pub fn new(
  method method: HTTPRequestMethod,
  headers headers: List(#(String, String)),
  path path: String,
  body body: Option(String),
  http_version http_version: String,
) -> HTTPRequest {
  HTTPRequest(
    method: method,
    headers: headers,
    path: path,
    body: body,
    http_version: http_version,
    accepts_encodings: headers
      |> list.find(fn(header) { header.0 == "accept-encoding" })
      |> option.from_result
      |> option.map(fn(header) {
        header.1
        |> string.split(",")
        |> list.map(compression_scheme_from_string)
        |> list.unique
      })
      |> option.unwrap([NoCompression]),
  )
}

pub fn parse_method(
  method: String,
) -> Result(HTTPRequestMethod, UnknownHTTPRequestMethod) {
  case method {
    "GET" -> Ok(GET)
    "POST" -> Ok(POST)
    "PUT" -> Ok(PUT)
    "DELETE" -> Ok(DELETE)

    "HEAD" -> Ok(HEAD)
    "CONNECT" -> Ok(CONNECT)
    "OPTIONS" -> Ok(OPTIONS)
    "TRACE" -> Ok(TRACE)
    "PATCH" -> Ok(PATCH)

    _ -> Error(UnknownHTTPRequestMethod)
  }
}
