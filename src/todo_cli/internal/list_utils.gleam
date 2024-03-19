import gleam/list

pub fn join(lst: List(String), unifier: String) -> String {
  lst
  |> list.fold("", fn(a, b) { a <> unifier <> b })
}
