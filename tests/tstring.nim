import times, sugar

# compile with -d:release -d:danger

proc copy1(src: string, len: int = src.len): string =
  result = newString(len)
  for i,c in src:
    result[i] = c
    if i == len - 1: break

proc copy2(src: string, len: int = src.len): string =
  result = newString(len)
  for i,c in src:
    if i >= len: break
    result[i] = c

proc copy3(src: string, len: int = src.len): string =
  result = newString(len)
  for i,c in src:
    if i < len: result[i] = c
    else: break

proc copy4(src: string, len: int = src.len): string =
  result = newString(len)
  let limit = if src.len < len: src.len else: len
  for i in 0..<limit:
     result[i] = src[i]

const Source = "Goodbye Cruel World, Goodbye Cruel World, Goodbye Cruel World, Goodbye Cruel World"
const Cycles = 200_000_000
var tim: seq[float]


proc testCopy(name: string, copy: (string, int) -> string, src: string, limit: int = src.len, cycles: int): float =
  echo "Testing: ", name
  var time = cpuTime()
  var str: string
  for i in 1..cycles:
    str = src.copy(limit)
  result = cpuTime() - time
  echo "Time taken: ", result, "\n"

tim.add(testCopy("copy 4", copy4, Source, cycles = Cycles)) # winnder and it's not even close
tim.add(testCopy("copy 3", copy3, Source, cycles = Cycles)) # shit
tim.add(testCopy("copy 2", copy2, Source, cycles = Cycles)) # shit
tim.add(testCopy("copy 1", copy1, Source, cycles = Cycles)) # shit

