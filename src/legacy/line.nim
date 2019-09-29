import
  listsv

#const decl
const GapSize = 32

#type decl
type
  Location* = tuple
    linelink: DoubleLink[Line]
    offset: int

  Mark* = ref object
    pos: Location
    fixed: bool
    name: string

  Line* = ref object
    data: string
    gs: int
    ge: int
    marks: LinkedList[Mark]

#func decl
proc newLine*(data: string = ""): Line

proc gapsize*(line: Line): int {.inline.} = line.ge - line.gs

proc copyTo(src: string, dst: var string)

proc insert*(line: var Line, s: string, offset: int)
proc insert*(line: var Line, c: char, offset: int)
proc delete*(line: var Line, offset: int)

proc expandgap(line: var Line, size: int)
proc movegap(line: var Line, offset: int)

proc addMark*(line: Line, name: string, location: Location, fixed: bool = true)
proc moveMark*(line: Line, name: string, x: int)
proc removeMark*(line: Line, name: string)
proc markLink*(line: Line, name: string): Link[Mark]
proc mark*(line: Line, name: string): Mark

proc text*(line: Line): string
proc `$`*(line: Line): string

#func decl
proc newLine(data: string): Line = 
  result = Line()
  let size = data.len + GapSize
  result.data = newString(size)
  data.copyTo(result.data)
  result.gs = data.len
  result.ge = size

proc copyTo(src: string, dst: var string) =
  if src.len > dst.len:
    dst = newString(src.len)
    for i,c in src:
      dst[i] = c
  else:
    for i,c in dst:
      dst[i] = if i < src.len: src[i] else: char(0)

proc insert(line: var Line, s: string, offset: int) = 
  for i,c in s:
    line.insert(c, offset+i)

proc insert(line: var Line, c: char, offset: int) =
  if line.gapsize < 1: line.expandgap(GapSize)
  line.movegap(offset)
  line.data[line.gs] = c
  inc(line.gs)

proc delete(line: var Line, offset: int) =
  if offset < 1: return
  line.movegap(offset)
  line.data[offset-1] = char(0)
  dec(line.gs)

proc expandgap(line: var Line, size: int) =
  let data = line.data
  line.data = newString(data.len + size)
  data.copyTo(line.data)
  line.gs = data.len
  line.ge = line.data.len
  
proc movegap(line: var Line, offset: int) =
  if offset == line.gs: return
  let shift = line.gs - offset
  if offset < line.gs:
    for i in 1..abs(shift):
      line.data[line.ge - i] = line.data[line.gs - i]
      line.data[line.gs - i] = char(0)
  else:
    for i in 0..<abs(shift):
      line.data[line.gs + i] = line.data[line.ge + i]
      line.data[line.ge + i] = char(0)

  line.gs = offset
  line.ge -= shift


proc addMark*(line: Line, name: string, location: Location, fixed: bool = true) =
  var linelink = location.linelink
  var marks = linelink.value.marks
  let nMark = marks.newLink(Mark(name: name, pos: location, fixed: fixed))
  
  for mark in marks.links:
    if mark.value.pos.offset > nMark.value.pos.offset:
      marks.insertBefore(nMark, mark)

proc moveMark*(line: Line, name: string, x: int) =
  var mark = line.mark(name)
  let offset = mark.pos.offset
  for i in 0..<abs(x):
    if x > 0:
      if offset >= line.text.len-1: break
      inc(mark.pos.offset)
    else:
      if offset <= 0: break
      dec(mark.pos.offset)

proc removeMark*(line: Line, name: string) =
  let marklink = line.markLink(name)
  line.marks.remove(marklink)

proc markLink(line: Line, name: string): Link[Mark] =
  for mark in line.marks.links:
    if mark.value.name == name:
      return mark

proc mark(line: Line, name: string): Mark =
  for mark in line.marks.values:
    if mark.name == name:
      return mark

proc text(line: Line): string =
  for i in 0..<line.data.len-line.gapsize:
    if i <= line.gs: result&=line.data[i]
    else: result&=line.data[i+line.gs]

proc `$`(line: Line): string =
  for c in line.data:
      if c == char(0): result&='_'
      else: result&=c