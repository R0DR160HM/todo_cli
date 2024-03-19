import gleam/list
import gleam/string
import ids/uuid
import simplifile

const filepath = "tasks.csv"

pub type Status {
  Backlog
  Todo
  InProgress
  Done
}

pub type Task {
  Task(id: String, description: String, status: Status)
}

pub fn to_csv(task: Task) -> String {
  case task.status {
    Backlog -> task.id <> ";" <> task.description <> ";0\n"
    Todo -> task.id <> ";" <> task.description <> ";1\n"
    InProgress -> task.id <> ";" <> task.description <> ";2\n"
    Done -> task.id <> ";" <> task.description <> ";3\n"
  }
}

pub fn create(description: String) -> Task {
  let assert Ok(id) = uuid.generate_v7()
  let task = Task(id, description, Backlog)
  let abc =
    task
    |> to_csv
    |> simplifile.append(to: filepath)
  case abc {
    Ok(_) -> task
    Error(_) -> {
      let assert Ok(_) = write("")
      create(description)
    }
  }
  task
}

pub fn list() -> List(Task) {
  case simplifile.read(from: filepath) {
    Ok(text) -> parse(text)
    Error(_) -> {
      let assert Ok(_) = write("")
      []
    }
  }
}

pub fn update_status(old_task: Task, status: Status) -> Task {
  let tasks = list()
  let task = Task(old_task.id, old_task.description, status)
  tasks
  |> list.map(fn(t) {
    case t.id {
      identifier if identifier == task.id -> task
      _ -> t
    }
  })
  |> persist_all
  task
}

pub fn upgrade(task: Task) -> Task {
  case task.status {
    Backlog -> update_status(task, Todo)
    Todo -> update_status(task, InProgress)
    InProgress -> update_status(task, Done)
    Done -> task
  }
}

pub fn downgrade(task: Task) -> Task {
  case task.status {
    Backlog -> task
    Todo -> update_status(task, Backlog)
    InProgress -> update_status(task, Todo)
    Done -> update_status(task, InProgress)
  }
}

pub fn get(id: String) -> Task {
  let tasks = list()
  let assert Ok(task) =
    tasks
    |> list.find(fn(t) { t.id == id })
  task
}

pub fn delete(id: String) {
  list()
  |> list.filter(fn(task) { task.id != id })
  |> persist_all
}

pub fn close_all_done() {
  list()
  |> list.filter(fn(task) { task.status != Done })
  |> persist_all
  list()
}

fn write(value: String) {
  // let assert Ok(_) = simplifile.create_file(filepath)
  value
  |> simplifile.write(to: filepath)
}

fn parse(text: String) -> List(Task) {
  text
  |> string.split("\n")
  |> list.filter(fn(line) { line != "" })
  |> list.map(fn(line) {
    line
    |> csv_to_task
  })
}

fn csv_to_task(csv: String) -> Task {
  let values =
    csv
    |> string.split(";")
  case values {
    [id, description, "0"] -> Task(id, description, Backlog)
    [id, description, "1"] -> Task(id, description, Todo)
    [id, description, "2"] -> Task(id, description, InProgress)
    [id, description, "3"] -> Task(id, description, Done)
    _ -> panic("Invalid CSV")
  }
}

fn persist_all(tasks: List(Task)) {
  let assert Ok(_) = write("")
  persist_all_internal(tasks)
}

fn persist_all_internal(tasks: List(Task)) {
  let result =
    tasks
    |> list.pop(fn(_) { True })
  case result {
    Ok(#(task, remaining)) -> {
      let assert Ok(_) =
        task
        |> to_csv
        |> simplifile.append(to: filepath)
      persist_all_internal(remaining)
    }
    Error(_) -> Nil
  }
}

pub fn read(task: Task) {
  task.id <> ": " <> task.description
}
