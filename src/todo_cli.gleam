import gleam/io
import gleam/list
import argv
import todo_cli/tasks
import todo_cli/list_utils
import colored

pub fn main() {
  case argv.load().arguments {
    ["list"] -> list_items()
    ["info", ..id] | ["view", ..id] | ["see", ..id] -> {
      id
      |> list_utils.join(" ")
      |> view_item
    }
    ["add", ..descriptions] -> {
      descriptions
      |> list_utils.join(" ")
      |> add_item
    }
    ["upgrade", ..id] -> {
      id
      |> list_utils.join(" ")
      |> upgrade_item
    }
    ["downgrade", ..id] -> {
      id
      |> list_utils.join(" ")
      |> downgrade_item
    }
    ["close", ..id] | ["delete", ..id] | ["remove", ..id] -> {
      id
      |> list_utils.join(" ")
      |> close_item
    }
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
  io.println("----- COMMANDS -----")
  print_help("list", "\t", "\tList all tasks.")
  print_help("info", "task", "\tView a task.")
  print_help("add", "description", "\tAdd a task.")
  print_help("upgrade", "task", "\tUpgrade task to next stage.")
  print_help("downgrade", "task", "Downgrade task to previous stage.")
  print_help("close", "task", "\tClose a task.")
  print_help("clean", "\t", "\tClose all done tasks.")
  Nil
}

fn print_help(command: String, args: String, description: String) {
  io.println(
    colored.cyan(command) <> " " <> colored.yellow(args) <> "\t" <> description,
  )
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
