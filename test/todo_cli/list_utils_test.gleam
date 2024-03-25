import gleeunit/should
import todo_cli/list_utils

pub fn join_test() {
  ["a", "b", "c"]
  |> list_utils.join(", ")
  |> should.equal("a, b, c")
  ["There", "once", "was", "a", "man", "from", "Nantucket"]
  |> list_utils.join(" ")
  |> should.equal("There once was a man from Nantucket")
}
