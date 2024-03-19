import gleam/io
import gleam/list
import argv
import todo_cli/internal/tasks
import todo_cli/internal/list_utils

pub fn main() {
  case argv.load().arguments {
    [] | ["list"] -> list_items()
    ["see", id] | ["view", id] | ["info", id] -> view_item(id)
    ["add", ..descriptions] -> {
      descriptions
      |> list_utils.join(" ")
      |> add_item
    }
    ["upgrade", id] -> upgrade_item(id)
    ["downgrade", id] -> downgrade_item(id)
    ["close", id] | ["delete", id] -> close_item(id)
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
  print()
}

fn upgrade_item(id_code: String) {
  tasks.get(id_code)
  |> tasks.upgrade
  print()
}

fn downgrade_item(id_code: String) {
  tasks.get(id_code)
  |> tasks.downgrade
  print()
}

fn view_item(id_code: String) {
  tasks.get(id_code)
  |> io.debug
  Nil
}

fn close_item(id_code: String) {
  tasks.delete(id_code)
  tasks.list()
  print()
  Nil
}

fn clean_items() {
  tasks.close_all_done()
  print()
}

fn help() {
  io.debug("")
  Nil
}

fn print() {
  tasks.list()
  |> print_internal(
    "------------------------------------- Anotações -------------------------------------",
    tasks.Backlog,
  )
  |> print_internal(
    "-------------------------------------- A fazer --------------------------------------",
    tasks.Todo,
  )
  |> print_internal(
    "------------------------------------ Em andamento -----------------------------------",
    tasks.InProgress,
  )
  |> print_internal(
    "-------------------------------------- Feitas ---------------------------------------",
    tasks.Done,
  )
  Nil
}

fn print_internal(
  my_tasks: List(tasks.Task),
  title: String,
  status: tasks.Status,
) -> List(tasks.Task) {
  io.println("\n" <> title)
  my_tasks
  |> list.filter(fn(task) { task.status == status })
  |> list.each(fn(task) {
    task
    |> tasks.read
    |> io.println
  })
  my_tasks
}
