import gleam/io
import gleam/list
import argv
import todo_cli/tasks
import todo_cli/list_utils
import colored

pub fn main() {
  case argv.load().arguments {
    //List
    ["l" <> _] -> list_items()
    //Info
    ["i" <> _, ..id] -> {
      id
      |> list_utils.join(" ")
      |> view_item
    }
    //Add
    ["a" <> _, ..descriptions] -> {
      descriptions
      |> list_utils.join(" ")
      |> add_item
    }
    //Upgrade
    ["u" <> _, ..id] -> {
      id
      |> list_utils.join(" ")
      |> upgrade_item
    }
    //Downgrade
    ["d" <> _, ..id] -> {
      id
      |> list_utils.join(" ")
      |> downgrade_item
    }
    //Remove
    ["r" <> _, ..id] -> {
      id
      |> list_utils.join(" ")
      |> close_item
    }
    ["c" <> _] -> clean_items()
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
  print_help("list", "\t", "List all tasks.")
  print_help("info", "task", "View a task.")
  print_help("add", "description", "Add a task.")
  print_help("upgrade", "task", "Upgrade task to next stage.")
  print_help("downgrade", "task", "Downgrade task to previous stage.")
  print_help("remove", "task", "Close a task.")
  print_help("clean", "\t", "Close all done tasks.")
  Nil
}

fn print_help(command: String, args: String, description: String) {
  io.println(
    colored.cyan(command)
    <> " "
    <> colored.yellow(args)
    <> "\t\t"
    <> description,
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
