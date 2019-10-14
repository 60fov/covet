import os, sugar
var filepath = "res" / "test.txt"

var file = open(filepath, fmRead)

proc q() {.noconv.} = close(file)

addQuitProc(q)

while true:
  file
  sleep(1000)