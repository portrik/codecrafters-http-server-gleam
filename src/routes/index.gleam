import gleam/list
import gleam/option

import request/request.{type HTTPRequest}
import response/response.{type HTTPResponse}

pub fn index(_request: HTTPRequest) -> HTTPResponse {
  response.HTTPResponse(response.OK, list.new(), option.None)
}
