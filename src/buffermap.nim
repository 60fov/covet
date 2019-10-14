import lists
include line

type
  BufferMap* = ref object
    lines: DoublyLinkedList[LineBuffer]
    name: string
    caret: Position
    lc, cc: int
    data*: LineBuffer
    wrap: bool
    filename: string
    lastsync: int
    modified: bool

  Position = object
    line, offset: int

const BufferSize = 1024

proc createBufferMap*(name: string): BufferMap

proc load*(map: BufferMap, filepath: string)

proc linecount*(map: BufferMap): int {.inline.} = map.lc
proc charcount*(map: BufferMap): int {.inline.} = map.cc
proc wrap*(map: BufferMap): bool {.inline.} = map.wrap

proc createBufferMap*(name: string): BufferMap =
  new result
  result.name = name
  result.lines = initDoublyLinkedList[LineBuffer]()
  result.caret = Position(line: 0, offset: 0)
  result.wrap = false

proc load*(map: BufferMap, filepath: string) =
  var bytes: array[BufferSize, uint8]
  var file: File
  var pos: int
  var rbc: int = BufferSize
  var data: string
  if open(file, filepath, fmRead):
    while rbc == BufferSize:
      rbc = file.readBytes(bytes, pos, bytes.len)
      for b in bytes:
        case b:
        of '\r'.uint8:
          inc(map.lc)
          map.lines.append(createLineBuffer(data))
          data = ""
        of '\n'.uint8: continue
        else:
          data &= b.char
          inc(map.cc)
  else:
    echo "failed to open file"

proc line*(map: BufferMap, row: int): LineBuffer =
  var node = map.lines.head
  if node == nil: return
  result = node.value
  var i = 1
  while i != row:
    inc i
    node = node.next
  
  return node.value