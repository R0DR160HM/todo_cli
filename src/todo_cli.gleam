import gleam/io
import gleam/list
import argv
import todo_cli/tasks
import todo_cli/list_utils

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
  |> tasks.print
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
  |> tasks.print
  Nil
}

fn close_item(id_code: String) {
  let assert Ok(_) = tasks.delete(id_code)
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
  io.println("\n\n\n")
  tasks.list()
  |> print_internal("ANOTAÇÕES", tasks.Backlog)
  |> print_internal("A FAZER", tasks.Todo)
  |> print_internal("EM ANDAMENTO", tasks.InProgress)
  |> print_internal("FEITAS", tasks.Done)
  Nil
}

fn print_internal(
  my_tasks: List(tasks.Task),
  title: String,
  status: tasks.Status,
) -> List(tasks.Task) {
  { "\n" <> title <> "\n" }
  |> tasks.status_color(status)
  |> io.println

  my_tasks
  |> list.filter(fn(task) { task.status == status })
  |> list.each(fn(task) {
    task
    |> tasks.print
  })

  io.println("")
  my_tasks
}
