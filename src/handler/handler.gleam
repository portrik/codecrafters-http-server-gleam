import gleam/bit_array
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/list
import gleam/option
import gleam/otp/actor.{type Next}
import gleam/result

import glisten.{type Connection, type Message}

import request/parse
import request/request.{type HTTPRequest}
import response/format
import response/response.{type HTTPResponse}
import router/actor as router

fn read_request(message: Message(user_message)) -> Result(HTTPRequest, Nil) {
  case message {
    glisten.Packet(content) -> {
      use string_content <- result.try(content |> bit_array.to_string)

      string_content |> parse.parse_request |> result.replace_error(Nil)
    }
    _ -> Error(Nil)
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
    Ok(request) -> get_response(router_actor, request)
    Error(_) ->
      response.HTTPResponse(response.BadRequest, list.new(), option.None)
  }

  let compression_options = case request {
    Ok(request) -> request.accepts_encodings
    Error(_) -> [request.NoCompression]
  }

  io.println("Sending response.")

  let response = response |> format.format_response(compression_options)
  io.debug(response)

  case glisten.send(connection, response) {
    Ok(_) -> io.println("Response sent successfully")
    Error(error) -> {
      io.debug(error)
      io.print_error("Failed to send response.")
    }
  }

  io.println("Finished connection.")
  actor.continue(state)
}
