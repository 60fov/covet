import
  strutils,
  listsv,
  ospaths,
  os,
  strformat,
  util/misc,
  line

#type decl
type
  Body* = ref object
    linelist: LinkedList[Line]
    point: Location
    curline*: int
    linecount: int

#func decl
proc createBody*(): Body

proc read*(body: var Body, file: File)

proc len*(body: Body): int {.inline.} = body.linelist.len

proc linelist*(body: Body): LinkedList[Line] {.inline.} = body.linelist
proc linelink*(body: Body): DoubleLink[Line] {.inline.} = body.point.linelink
proc linelink(body: var Body): var DoubleLink[Line] {.inline.} = body.point.linelink
proc lineLinkAt*(body: Body, row: int): DoubleLink[Line]
proc line*(body: Body): Line {.inline.} = body.point.linelink.value
proc line(body: var Body): var Line {.inline.} = body.point.linelink.value

proc insert*(body: var Body, c: char)
proc insert*(body: var Body, str: string)
proc insert*(body: var Body, line: Line)
proc replace*(body: var Body, c: char)
proc replace*(body: var Body, str: string)
proc replace*(body: var Body, line: Line)
proc delete*(body: var Body, count: int)
proc deleteLine*(body: var Body)

proc point*(body: Body): Location {.inline.} = body.point
proc movepoint*(body: var Body, row, col: int)
proc setpoint*(body: var Body, row, col: int)

proc destroy*(body: Body)

#func imple
proc createBody(): Body =
  var list = createLinkedList[Line](ltDouble)

  result = Body(
    linelist: list,
    point: (nil, 0),
    curline: 1
  )

proc read(body: var Body, file: File) = 
  while not endOfFile(file):
    body.linelist.append(newLine(readLine(file)))

  body.point.linelink = DoubleLink[Line]body.linelist.head
  
proc insert*(body: var Body, c: char) =
  body.line.insert(c, body.point.offset)
  inc(body.point.offset)

proc insert*(body: var Body, str: string) =
  for i,c in str:
    body.insert(c)

proc insert*(body: var Body, line: Line) =
  if body.linelist.len < 1:
    body.linelist.append(line)
    body.point.linelink = DoubleLink[Line](body.linelist.head)
  else:
    let link = body.linelist.newLink(line)
    body.linelist.insertAfter(link, body.linelink)
    body.movepoint(1, 0)
    
proc replace*(body: var Body, c: char) =
  body.delete(1)
  body.line.insert(c, body.point.offset)

proc replace*(body: var Body, str: string) =
  for c in str:
    body.replace(c)
    
proc replace*(body: var Body, line: Line) =
  body.deleteLine()
  body.insert(line)

#NOTE: count < 0 delete left
proc delete*(body: var Body, count: int) =
  for i in 0..count:
    body.line.delete(body.point.offset+i)

proc deleteLine*(body: var Body) = discard

proc movepoint*(body: var Body, row, col: int) = 
  for i in 0..<abs(row):
    if row > 0:
      if body.curline >= body.linelist.len: break
      inc(body.curline)
      body.point.linelink = DoubleLink[Line](body.linelink.next)
    else:
      if body.curline <= 1: break
      dec(body.curline)
      body.point.linelink = body.linelink.prev
  

  for i in 0..<abs(col):
    if col > 0:
      if body.point.offset >= body.line.text.len-1: break
      inc(body.point.offset)
    else:
      if body.point.offset <= 0: break
      dec(body.point.offset)


proc setpoint*(body: var Body, row, col: int) = 
  if row.inrange(1, body.linelist.len):
    body.curline = row
    body.point.linelink = body.lineLinkAt(row)


proc lineLinkAt(body: Body, row: int): DoubleLink[Line] =
  if row == 0:
    echo "line index starts at 1 silly"
    return
    
  var i = 0
  for link in body.linelist.links:
    inc(i)
    if i == row: return DoubleLink[Line](link)


proc destroy(body: Body) =
  if body.linelist != nil: body.linelist.clear()
  body.point.linelink = nil
  #TODO: Destroy marks if implemented