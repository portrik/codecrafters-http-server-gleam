import gleam/bytes_tree
import gleam/io
import gleam/list
import gleam/otp/actor.{type Next}
import response/format
import response/response

import glisten.{type Connection, type Message}

pub fn connection_handler(
  message: Message(user_message),
  state: Nil,
  connection: Connection(user_message),
) -> Next(Message(user_message), Nil) {
  io.println("Received message.")
  io.debug(message)

  let status = response.create_status(200)
  let response = format.format_response(status, list.new(), "")

  io.println("Sending response.")
  io.debug(response)

  let assert Ok(_) =
    connection
    |> glisten.send(bytes_tree.from_string(response))

  io.println("Finished connection.")
  actor.continue(state)
}
