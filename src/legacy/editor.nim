import
  sdl2/sdl,
  listsv

import
  os, ospaths,
  strutils,
  strformat

import
  bitmapfont,
  textdata,
  line,
  bitmapfont,
  util/misc

#[
  TODO: 
    window resize/move
    per side padding/border
    read/write
    syntax highlighter
    linter
]#

#const decl
const 
  BasePath = r"D:\dev\sandbox\nim\text_editor\bin"
  White = Color(r: 255, g: 255, b: 255)
  Gray = Color(r: 127, g: 127, b: 127)
  Black = Color()
  Red = Color(r: 255)
  Green = Color(g: 255)
  Blue = Color(b: 255)
  Yellow = Color(r: 255, g: 255)
  Magenta = Color(r: 255, b: 255)
  Cyan = Color(g: 255, b: 255)

const DefBorderColor = Cyan
const DefFgColor = White
const DefBgColor = Black
const DefText = White
const DefTextAlt = Gray

#type decl
type
  View* = ref object of RootObj
    win: Window
    surface: Surface
    renderer: Renderer
    surfaceUpdated: bool
    color: tuple[fg, bg, text, textalt: Color]
    border: int
    padding: int
    w, h: int

  #[
    NOTE:
      editor's w and h managed on a cell basis
      the font determines the cell size
      resize operations function on the "cellular" level
  ]#
  Editor* = ref object of View
    data: Body
    font: BitmapFont
    filepath: string
    cw, ch, dwidth: int
    top: int
    firstline, lastline: Link[Line]
    lineNumbersEnabled: bool

#func decl
proc createEditor*(
  font: BitmapFont, 
  x = WINDOWPOS_CENTERED, y = WINDOWPOS_CENTERED,
  cellw = 128, cellh = 48,
  border = 4, padding = 10): Editor


proc renderDecorations(v: View)
proc renderLineNumber(e: Editor, lineIndex: int, color: uint32)
proc renderGlyph(e: Editor, glyph: Glyph, x, y: int, color: uint32)
# proc renderText(e: Editor, line: string, x, y: int, color: uint32)

proc render*(e: Editor)
proc handle*(e: Editor, event: Event)

proc scroll(e: Editor, y: int)

proc setFilePath*(e: Editor, path: string)
proc filepath*(e: Editor): string {.inline.} = e.filepath
proc `font=`*(e: Editor, font: BitmapFont) {.inline.} = e.font = font
proc font*(e: Editor): BitmapFont {.inline.} = e.font

proc read*(e: Editor)
proc write*(e: Editor)

proc destroyView(v: View)
proc destroy*(e: Editor)

#func imple
proc createEditor(font: BitmapFont, x, y, cellw, cellh, border, padding: int): Editor =
  let glyph = font.getGlyph('a'.uint16)
  let width = cellw * glyph.dwidth + (padding + border) * 2
  let height = cellh * font.box.h + (padding + border) * 2
  let window = createWindow("Editor", x, y, width, height, WINDOW_BORDERLESS or WINDOW_SHOWN)
  let surface = getWindowSurface(window)
  let renderer = createRenderer(window, -1, RENDERER_ACCELERATED)
  let data = createBody()

  result = Editor(
    win: window,
    surface: surface,
    renderer: renderer,
    font: font,
    top: 1,
    cw: cellw, ch: cellh, w: width, h: height, dwidth: glyph.dwidth,
    border: border, padding: padding,
    data: data,
    lineNumbersEnabled: true
  )

proc renderDecorations(v: View) =
  var rect = Rect()
  LOG_SDL fillRect(v.surface, nil, 0x0f0f0f)
  rect = Rect(x: v.border, y: v.border, w: v.w - (v.border*2), h: v.h - (v.border*2))
  LOG_SDL fillRect(v.surface, addr(rect), 0x222222)

proc renderLineNumber(e: Editor, lineIndex: int, color: uint32) =
  var lnWidth = ($e.data.len).len
  var lnStr = $(lineIndex + e.top - 1)
  var glyph: Glyph
  for i,c in lnStr:
    glyph = e.font.getGlyph(c.uint16)
    var x = lnWidth - lnStr.len + i #TODO: fix
    var y = lineIndex
    renderGlyph(e, glyph, x, y, color)

proc renderGlyph(e: Editor, glyph: Glyph, x, y: int, color: uint32) =
  var dst = Rect(x: 0, y: 0)
  dst.x = (e.border + e.padding) + ((x * e.dwidth) + glyph.box.x) # window decor / cell pos
  dst.y = (e.border + e.padding) + ((y * e.font.box.h) - glyph.box.h - glyph.box.y) #window decor / char pos in cell
  var mask = createRGBSurfaceWithFormat(0, glyph.bitmap.w, glyph.bitmap.h, 32, glyph.bitmap.format.format)
  LOG_SDL fillRect(mask, nil, color)
  LOG_SDL setSurfaceBlendMode(mask, BLENDMODE_MOD)
  var bitmapCopy: Surface
  copySurface(bitmapCopy, glyph.bitmap)
  unlockSurface(bitmapCopy)
  unlockSurface(mask)
  unlockSurface(glyph.bitmap)
  LOG_SDL blitSurface(mask, nil, bitmapCopy, nil)
  LOG_SDL setSurfaceBlendMode(bitmapCopy, BLENDMODE_ADD)
  LOG_SDL blitSurface(bitmapCopy, nil, e.surface, addr(dst))
  free bitmapCopy
  free mask

#proc renderText(e: Editor, line: string, x, y: int, color: uint32)

proc render(e: Editor) =
  if not e.surfaceUpdated:
    #render clear
    LOG_SDL fillRect(e.surface, nil, 0)
    renderDecorations(e)
    #render body
    var line = e.firstline
    var lineNumber = 1
    while line != nil:
      #TODO: crash from this smh????
      if e.lineNumbersEnabled: renderLineNumber(e, lineNumber, 0xbb22ff'u32)
      # render line
      for xcell,c in line.value.text:
        # render glyph
        var glyph = e.font.getGlyph(c.uint16)
        var x = xcell
        if e.lineNumbersEnabled: x += len($e.data.len) + 1
        if glyph != nil: renderGlyph(e, glyph, x, lineNumber, 0x0ffadf'u32)

      if line == e.lastline: break
      line = line.next
      inc(lineNumber)
    
    LOG_SDL updateWindowSurface(e.win)
    e.surfaceUpdated = true

proc handle(e: Editor, event: Event) = 
  case event.kind
  of MouseWheel: e.scroll(event.wheel.y)
  else: return
  e.surfaceUpdated = false

proc scroll(e: Editor, y: int) =
  e.top -= y
  if e.top < 1: e.top = 1
  if e.top > e.data.len - e.ch + 1: e.top = e.data.len - e.ch + 1
  e.firstline = e.data.lineLinkAt(e.top)
  e.lastline = e.data.lineLinkAt(e.top + e.ch-1)

proc setFilePath(e: Editor, path: string) = 
  var filepath = 
    if path.isAbsolute(): path
    else: joinPath([BasePath, path])

  if existsFile(filepath):
    e.filepath = filepath

#NOTE: close and open file on read and write
proc read(e: Editor) =
  let file = open(e.filepath)
  e.data.read(file)
  close(file)
  e.scroll(e.top)

proc write(e: Editor) =
  var file = open(e.filepath)
  #TODO: write
  close(file)

proc destroyView(v: View) =
  destroyRenderer(v.renderer)
  destroyWindow(v.win)

proc destroy(e: Editor) =
  destroy(e.font)
  destroy(e.data)
  destroyView(e)