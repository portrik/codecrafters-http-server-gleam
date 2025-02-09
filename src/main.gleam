import gleam/io
import gleam/list
import gleam/erlang/process
import gleam/option.{None}

import glisten

import handler/handler
import request/request.{type HTTPRequestMethod}
import router/actor
import router/router.{type RouteHandler}
import routes/echo_route
import routes/index

type Route {
  Route(path: String, method: HTTPRequestMethod, handler: RouteHandler)
}

const routes: List(Route) = [
  Route(path: "/", method: request.GET, handler: index.index),
  Route(
    path: "/echo/{string}",
    method: request.GET,
    handler: echo_route.echo_route,
  ),
]

pub fn main() {
  io.println("Starting server")

  let assert Ok(router_actor) = actor.new()

  routes
  |> list.each(fn(route) {
    router_actor
    |> actor.add_route(route.path, route.method, route.handler)
  })

  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(message, state, connection) {
      handler.connection_handler(router_actor, message, state, connection)
    })
    |> glisten.serve(4221)

  process.sleep_forever()
}
