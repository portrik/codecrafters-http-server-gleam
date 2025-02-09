import gleam/option.{type Option}

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
  )
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
