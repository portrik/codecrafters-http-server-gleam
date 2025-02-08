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
  Request(
    method: HTTPRequestMethod,
    headers: List(#(String, String)),
    path: String,
    body: Option(String),
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
