import gleam/int
import gleam/list
import gleam/option
import gleam/string

import request/request.{type HTTPRequest}
import response/response.{type HTTPResponse}

pub fn echo_route(request: HTTPRequest) -> HTTPResponse {
  let segments =
    request.path
    |> string.split("/")
    |> list.filter(fn(segment) { !string.is_empty(segment) })

  case segments {
    ["echo", to_echo] ->
      response.HTTPResponse(
        status: response.OK,
        headers: [
          #("Content-Type", "text/plain"),
          #("Content-Length", to_echo |> string.length |> int.to_string),
        ],
        body: option.Some(to_echo),
      )
    _ ->
      response.HTTPResponse(
        status: response.BadRequest,
        headers: list.new(),
        body: option.None,
      )
  }
}
