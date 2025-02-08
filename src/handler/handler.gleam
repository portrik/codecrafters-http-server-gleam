import gleam/bit_array
import gleam/bytes_tree
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/otp/actor.{type Next}
import gleam/result
import request/parse

import glisten.{type Connection, type Message}

import request/request.{type HTTPRequest}
import response/format
import response/response

fn read_response(message: Message(user_message)) -> Option(HTTPRequest) {
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

pub fn connection_handler(
  message: Message(user_message),
  state: Nil,
  connection: Connection(user_message),
) -> Next(Message(user_message), Nil) {
  io.println("Received message.")
  io.debug(message)

  let request = read_response(message)
  let response = case request {
    option.Some(request.Request(request.GET, _, "/", _)) ->
      format.format_response(response.OK, list.new(), option.None)
    option.Some(request.Request(request.GET, _, _, _)) ->
      format.format_response(response.NotFound, list.new(), option.None)
    _ -> format.format_response(response.BadRequest, list.new(), option.None)
  }

  io.println("Sending response.")
  io.debug(response)

  let assert Ok(_) =
    connection
    |> glisten.send(bytes_tree.from_string(response))

  io.println("Finished connection.")
  actor.continue(state)
}
