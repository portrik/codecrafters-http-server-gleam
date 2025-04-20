import gleam/bit_array
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/otp/actor.{type Next}
import gleam/result
import request/parse

import glisten.{type Connection, type Message}

import request/request.{type HTTPRequest}
import response/format
import response/response.{type HTTPResponse}
import router/actor as router

fn read_request(message: Message(user_message)) -> Option(HTTPRequest) {
  case message {
    glisten.Packet(content) ->
      content
      |> bit_array.to_string
      |> result.map(fn(content) {
        content |> parse.parse_request |> option.from_result
      })
      |> option.from_result
      |> option.flatten
    _ -> option.None
  }
}

fn get_response(
  router_actor: Subject(router.Message),
  request: HTTPRequest,
) -> HTTPResponse {
  let handler =
    router_actor
    |> router.get_route(request.path, request.method)

  case handler {
    option.None ->
      response.HTTPResponse(response.NotFound, list.new(), option.None)
    option.Some(handler) -> handler(request)
  }
}

pub fn connection_handler(
  router_actor: Subject(router.Message),
  message: Message(user_message),
  state: Nil,
  connection: Connection(user_message),
) -> Next(Message(user_message), Nil) {
  io.println("Received message.")
  io.debug(message)

  let request = read_request(message)
  let response = case request {
    option.None ->
      response.HTTPResponse(response.BadRequest, list.new(), option.None)
    option.Some(request) -> get_response(router_actor, request)
  }

  io.println("Sending response.")

  let response = response |> format.format_response(request)
  io.debug(response)

  let assert Ok(_) =
    connection
    |> glisten.send(response)

  io.println("Finished connection.")
  actor.continue(state)
}
