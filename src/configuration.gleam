import gleam/io
import gleam/list
import simplifile

import argv

pub type Configuration {
  Configuration(file_directory: String)
}

fn fold_command_line_arguments(
  configuration: Configuration,
  current_arguments: List(String),
) -> Configuration {
  case current_arguments {
    ["--directory", directory] -> Configuration(file_directory: directory)
    _ -> configuration
  }
}

fn initialize_directory(path: String) -> Result(Nil, simplifile.FileError) {
  case simplifile.is_directory(path) {
    Ok(True) -> Ok(Nil)
    Ok(False) -> simplifile.create_directory_all(path)
    Error(error) -> Error(error)
  }
}

pub fn load_command_line() -> Configuration {
  let configuration =
    argv.load().arguments
    |> list.sized_chunk(2)
    |> list.fold(
      Configuration(file_directory: "/tmp/gleam-http-server"),
      fold_command_line_arguments,
    )

  case initialize_directory(configuration.file_directory) {
    Ok(_) -> io.debug("Configuration directory is successfully initialized.")
    Error(error) -> {
      io.debug(error)

      panic as "Provided directory does not exist and could not be created"
    }
  }

  configuration
}
