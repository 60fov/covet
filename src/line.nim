import strformat, strutils

#NOTE: probably want to change gap size access

type
  LineBuffer* = ref object
    prev: LineBuffer
    next: LineBuffer
    data: string
    gs: int
    ge: int

var GapSize* = 32

#func decl
proc createLineBuffer*(str: string = ""): LineBuffer

proc insert(line: var LineBuffer, c: char)
proc insertAt*(line: var LineBuffer, c: char, pos: int)
proc insertAt*(line: var LineBuffer, str: string, pos: int)

proc moveGapTo(line: var LineBuffer, pos: int)
proc expandGap(line: var LineBuffer, size: int = GapSize)

proc copyTo(src: string, dst: var string)
proc copy(src: string, len: int = src.len): string

proc text*(line: LineBuffer): string
proc `$`*(line: LineBuffer): string

proc gapsize(line: LineBuffer): int {.inline.} = line.ge - line.gs

#func decl
proc createLineBuffer(str: string = ""): LineBuffer =
  new result
  result.data = str.copy(str.len + GapSize)
  result.gs = str.len
  result.ge = result.data.len

proc insert(line: var LineBuffer, c: char) =
  line.data[line.gs] = c
  inc(line.gs)
  if line.gs == line.ge: line.expandGap()

proc insertAt(line: var LineBuffer, c: char, pos: int) =
  line.moveGapTo(pos)
  line.insert(c)

proc insertAt(line: var LineBuffer, str: string, pos: int) =
  line.moveGapTo(pos)
  for c in str:
    line.insert(c)

proc moveGapTo(line: var LineBuffer, pos: int) =
  if pos == line.gs: return
  let shift = line.gs - pos
  if pos < line.gs:
    for i in 1..abs(shift):
      line.data[line.ge - i] = line.data[line.gs - i]
      line.data[line.gs - i] = char(0)
  else:
    for i in 0..<abs(shift):
      line.data[line.gs + i] = line.data[line.ge + i]
      line.data[line.ge + i] = char(0)

  line.gs = pos
  line.ge -= shift

proc expandGap(line: var LineBuffer, size: int = GapSize) =
  let data = line.data
  line.data = newString(data.len + size)
  data.copyTo(line.data)
  line.gs = data.len
  line.ge = line.data.len

proc copyTo(src: string, dst: var string) =
  let limit = if src.len < dst.len: src.len else: dst.len
  for i in 0..<limit:
    dst[i] = src[i]

proc copy(src: string, len: int = src.len): string =
  result = newString(len)
  src.copyTo(result)

proc text(line: LineBuffer): string =
  let len = line.data.len - line.gapsize
  for i in 0..<len:
    if i > line.gs: result &= line.data[i+line.gs]
    else: result &= line.data[i]

proc `$`(line: LineBuffer): string =
  result &= "0"
  for i in 1..line.data.len:
    if i <= line.gs: result &= align($i, 4)
    elif i <= line.ge: result &= align("", 4)
    else: result &= align($(i-line.gapsize), 4)
  result &= "\n|"
  for c in line.data:
    var l = if c != char(0): c else: ' '
    result &= &" {l} |"
  result &= "\n-"
  for i in 1..line.data.len:
    result &= "----"
  result &= "\n0"
  for i in 1..line.data.len:
    result &= align($i, 4)
  result &= "\n "
  for i in 1..line.data.len:
    if i == line.gs: result &= align("GS", 4)
    elif i == line.ge: result &= align("GE", 4)
    else: result &= align("", 4)
  result &= "\n"