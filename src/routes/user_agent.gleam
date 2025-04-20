import gleam/list
import gleam/option
import gleam/string

import request/request.{type HTTPRequest}
import response/response.{type HTTPResponse}

pub fn user_agent(request: HTTPRequest) -> HTTPResponse {
  let user_agent =
    request.headers
    |> list.find(fn(header) { header.0 == "User-Agent" })

  case user_agent {
    Ok(#(_key, value)) ->
      response.HTTPResponse(
        status: response.OK,
        headers: [#("Content-Type", "text/plain")],
        body: option.Some(value |> string.trim),
      )
    _ ->
      response.HTTPResponse(
        status: response.BadRequest,
        headers: list.new(),
        body: option.None,
      )
  }
}
