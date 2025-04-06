import gleam/list
import gleam/option.{type Option}

import argv

pub type Configuration {
  Configuration(file_directory: Option(String))
}

fn fold_command_line_arguments(
  configuration: Configuration,
  current_arguments: List(String),
) -> Configuration {
  case current_arguments {
    ["--directory", directory] ->
      Configuration(file_directory: option.Some(directory))
    _ -> configuration
  }
}

pub fn load_command_line() -> Configuration {
  argv.load().arguments
  |> list.sized_chunk(2)
  |> list.fold(
    Configuration(file_directory: option.None),
    fold_command_line_arguments,
  )
}
