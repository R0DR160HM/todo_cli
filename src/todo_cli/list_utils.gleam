import gleam/list
import gleam/string

pub fn join(lst: List(String), unifier: String) -> String {
  lst
  |> list.fold("", fn(a, b) { a <> unifier <> b })
  |> string.drop_left(1)
}
