import gleam/io
import gleam/list
import argv
import todo_cli/internal/tasks

// import todo_cli/internal/db

pub fn main() {
  // io.debug(db.connect())
  case argv.load().arguments {
    [] | ["list"] -> list_items()
    ["see", id] | ["view", id] | ["info", id] -> view_item(id)
    ["add", ..descriptions] -> {
      io.debug(descriptions)
      descriptions
      |> list.fold("", fn(a, b) { a <> " " <> b })
      |> io.debug
      |> add_item
    }
    ["upgrade", id] -> upgrade_item(id)
    ["downgrade", id] -> downgrade_item(id)
    ["close", id] -> close_item(id)
    ["clean"] -> clean_items()
    _ -> help()
  }
}

fn add_item(description: String) -> Nil {
  tasks.create(description)
  |> io.debug
  Nil
}

fn list_items() {
  tasks.list()
  |> io.debug
  Nil
}

fn upgrade_item(id_code: String) {
  tasks.get(id_code)
  |> tasks.upgrade
  |> io.debug
  Nil
}

fn downgrade_item(id_code: String) {
  tasks.get(id_code)
  |> tasks.downgrade
  |> io.debug
  Nil
}

fn view_item(id_code: String) {
  tasks.get(id_code)
  |> io.debug
  Nil
}

fn close_item(id_code: String) {
  tasks.delete(id_code)
  tasks.list()
  |> io.debug
  Nil
}

fn clean_items() {
  tasks.close_all_done()
  |> io.debug
  Nil
}

fn help() {
  io.debug("")
  Nil
}
