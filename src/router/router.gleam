import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string

import request/request.{type HTTPRequest, type HTTPRequestMethod}
import response/response.{type HTTPResponse}

pub type RouteHandler =
  fn(HTTPRequest) -> HTTPResponse

pub type Route {
  Route(
    handlers: Option(Dict(HTTPRequestMethod, RouteHandler)),
    static_segments: Dict(String, Route),
    dynamic_segments: Dict(String, Route),
  )
}

pub type Router {
  Router(root: Route)
}

pub fn new() -> Router {
  Router(root: Route(
    handlers: option.None,
    static_segments: dict.new(),
    dynamic_segments: dict.new(),
  ))
}

pub fn add_route(
  router router: Router,
  path path: String,
  method method: HTTPRequestMethod,
  handler handler: RouteHandler,
) -> Router {
  let segments =
    path
    |> string.split("/")
    |> list.filter(fn(segment) { !string.is_empty(segment) })

  router.root
  |> add_segments(segments: segments, method: method, handler: handler)
  |> Router(root: _)
}

pub fn match_route(
  router: Router,
  path: String,
  method: HTTPRequestMethod,
) -> Option(RouteHandler) {
  let segments =
    path
    |> string.split("/")
    |> list.filter(fn(segment) { !string.is_empty(segment) })

  router.root
  |> find_segment(segments, method)
}

fn segment_is_dynamic(segment: String) -> Bool {
  let starts = segment |> string.starts_with("{")
  let ends = segment |> string.ends_with("}")

  bool.and(starts, ends)
}

fn add_dynamic_segment(
  current current: Route,
  segment segment: String,
  remaining_segments remaining_segments: List(String),
  method method: HTTPRequestMethod,
  handler handler: RouteHandler,
) -> Route {
  let segment = segment |> string.drop_start(1) |> string.drop_end(1)

  let existing_segment =
    current.dynamic_segments |> dict.get(segment) |> option.from_result

  let route = case existing_segment {
    option.Some(dynamic_segment) ->
      add_segments(dynamic_segment, remaining_segments, method, handler)
    option.None ->
      add_segments(
        Route(
          handlers: option.None,
          static_segments: dict.new(),
          dynamic_segments: dict.new(),
        ),
        remaining_segments,
        method,
        handler,
      )
  }

  Route(
    handlers: current.handlers,
    static_segments: current.static_segments,
    dynamic_segments: current.dynamic_segments |> dict.insert(segment, route),
  )
}

fn add_static_segment(
  current current: Route,
  segment segment: String,
  remaining_segments remaining_segments: List(String),
  method method: HTTPRequestMethod,
  handler handler: RouteHandler,
) -> Route {
  let existing_segment =
    current.static_segments |> dict.get(segment) |> option.from_result

  let route = case existing_segment {
    option.Some(static_segment) ->
      add_segments(static_segment, remaining_segments, method, handler)
    option.None ->
      add_segments(
        Route(
          handlers: option.None,
          static_segments: dict.new(),
          dynamic_segments: dict.new(),
        ),
        remaining_segments,
        method,
        handler,
      )
  }

  Route(
    handlers: current.handlers,
    static_segments: current.static_segments |> dict.insert(segment, route),
    dynamic_segments: current.dynamic_segments,
  )
}

fn add_handler(
  handlers: Option(Dict(HTTPRequestMethod, RouteHandler)),
  method: HTTPRequestMethod,
  handler: RouteHandler,
) -> Option(Dict(HTTPRequestMethod, RouteHandler)) {
  handlers
  |> option.unwrap(dict.new())
  |> dict.insert(method, handler)
  |> option.Some
}

fn add_segments(
  current current: Route,
  segments segments: List(String),
  method method: HTTPRequestMethod,
  handler handler: RouteHandler,
) -> Route {
  case segments {
    [] ->
      Route(
        handlers: add_handler(current.handlers, method, handler),
        static_segments: current.static_segments,
        dynamic_segments: current.dynamic_segments,
      )

    [segment, ..rest] ->
      case segment_is_dynamic(segment) {
        True ->
          add_dynamic_segment(
            current: current,
            segment: segment,
            remaining_segments: rest,
            method: method,
            handler: handler,
          )

        False ->
          add_static_segment(
            current: current,
            segment: segment,
            remaining_segments: rest,
            method: method,
            handler: handler,
          )
      }
  }
}

fn find_dynamic_segment(
  current: Route,
  segments: List(String),
  method: HTTPRequestMethod,
) -> Option(RouteHandler) {
  let route =
    current.dynamic_segments
    |> dict.values
    |> list.first
    |> option.from_result

  let rest =
    segments
    |> list.rest
    |> result.unwrap(list.new())

  case route {
    option.None -> option.None
    option.Some(route) -> find_segment(route, rest, method)
  }
}

fn find_static_segment(
  current: Route,
  segments: List(String),
  method: HTTPRequestMethod,
) -> Option(RouteHandler) {
  let route =
    segments
    |> list.first
    |> option.from_result
    |> option.map(fn(segment) {
      segment |> dict.get(current.static_segments, _) |> option.from_result
    })
    |> option.flatten

  let rest =
    segments
    |> list.rest
    |> result.unwrap(list.new())

  case route {
    option.None -> option.None
    option.Some(route) -> find_segment(route, rest, method)
  }
}

fn find_segment(
  current: Route,
  segments: List(String),
  method: HTTPRequestMethod,
) -> Option(RouteHandler) {
  case segments {
    [] ->
      current.handlers
      |> option.map(fn(handlers) {
        handlers |> dict.get(method) |> option.from_result
      })
      |> option.flatten

    [segment, ..] ->
      case dict.has_key(current.static_segments, segment) {
        False -> find_dynamic_segment(current, segments, method)
        True -> find_static_segment(current, segments, method)
      }
  }
}
