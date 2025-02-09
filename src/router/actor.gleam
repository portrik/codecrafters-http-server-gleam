import gleam/erlang/process.{type Subject}
import gleam/option.{type Option}
import gleam/otp/actor.{type Next, type StartError}

import request/request.{type HTTPRequestMethod}
import router/router.{type RouteHandler, type Router}

const timeout: Int = 5000

pub opaque type Message {
  Shutdown

  Register(path: String, method: HTTPRequestMethod, handler: RouteHandler)

  Get(
    path: String,
    method: HTTPRequestMethod,
    reply_with: Subject(Option(RouteHandler)),
  )
}

pub fn new() -> Result(Subject(Message), StartError) {
  router.new()
  |> actor.start(handle_message)
}

pub fn add_route(
  router: Subject(Message),
  path: String,
  method: HTTPRequestMethod,
  handler: RouteHandler,
) -> Nil {
  router
  |> actor.send(Register(path, method, handler))
}

pub fn get_route(
  router: Subject(Message),
  path: String,
  method: HTTPRequestMethod,
) -> Option(RouteHandler) {
  router
  |> actor.call(Get(path, method, _), timeout)
}

pub fn shut_down(router: Subject(Message)) -> Nil {
  router
  |> actor.send(Shutdown)
}

fn handle_message(message: Message, router: Router) -> Next(Message, Router) {
  case message {
    Shutdown ->
      process.Normal
      |> actor.Stop

    Register(path, method, handler) ->
      router
      |> router.add_route(path, method, handler)
      |> actor.continue

    Get(path, method, client) -> {
      router
      |> router.match_route(path, method)
      |> process.send(client, _)

      actor.continue(router)
    }
  }
}
