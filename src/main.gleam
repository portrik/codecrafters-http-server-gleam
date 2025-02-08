import gleam/io

import gleam/erlang/process
import gleam/option.{None}
import glisten

import handler/handler

pub fn main() {
  io.println("Starting server")

  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, handler.connection_handler)
    |> glisten.serve(4221)

  process.sleep_forever()
}
