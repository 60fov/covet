import os

hint("Processing", false)

task buildc, "nim c ..":
  setCommand("c")

task runc, "nim c -r ...":
  setCommand("c")
  switch("run")
  switch("outdir", "bin" / "dev")

task release, "release build":
  setCommand("c")
  switch("verbosity", "0")
  switch("outdir", "bin" / "release")
  switch("define", "release")
  switch("app", "gui")