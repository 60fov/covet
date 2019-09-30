import strutils, parseutils
import sdl2/sdl
import misc

const Clear = Color()
const White = Color(r: 255, g: 255, b: 255, a: 255)
type
  BDFGlyph* = ref BDFGlyphObj
  BDFGlyphObj = object
    bitmap*: Surface
    box: Rect
    code: uint16
    dwidth: int

  BDFFont* = ref BDFFontObj
  BDFFontObj = object
    name: string
    glyphs: array[uint16.high, BDFGlyph]
    descent: int
    ascent: int
    box: Rect
    color: Color


#func decl
proc loadBDFFont*(path: string): BDFFont
proc name*(font: BDFFont): string {.inline.} = font.name
proc glyph*(font: BDFFont, index: uint16): BDFGlyph {.inline.} = font.glyphs[index]
proc destroy*(font: BDFFont)

proc createGlyph(font: BDFFont, code: uint16, hexseq: seq[string], box: Rect, dw: int)
proc w*(glyph: BDFGlyph): int {.inline.} = glyph.box.w 
proc h*(glyph: BDFGlyph): int {.inline.} = glyph.box.h 
proc x*(glyph: BDFGlyph): int {.inline.} = glyph.box.x 
proc y*(glyph: BDFGlyph): int {.inline.} = glyph.box.y 
proc dw*(glyph: BDFGlyph): int {.inline.} = glyph.dwidth 
proc destroy(glyph: BDFGlyph) {.inline.} = free(glyph.bitmap)

#func imple
proc loadBDFFont*(path: string): BDFFont =
  new result
  
  var code, dw: int
  var box: Rect
  let file = open(path)
  while not endOfFile(file):
    var data = file.readLine().split()
    for i,d in data: data[i] = d.multiReplace(("\"", ""))
   
    case data[0]:
    of "FACE_NAME": result.name = data[1]
    of "FONT_DESCENT": result.descent = parseInt data[1]
    of "FONT_ASCENT": result.ascent = parseInt data[1]
    of "ENCODING": code = parseInt data[1]
    of "DWIDTH": dw = parseInt data[1]
    of "BBX":
      box = Rect(
        w: parseInt data[1],
        h: parseInt data[2],
        x: parseInt data[3],
        y: parseInt data[4]
      )
    of "FONTBOUNDINGBOX":
      result.box = Rect(
        w: parseInt data[1],
        h: parseInt data[2],
        x: parseInt data[3],
        y: parseInt data[4]
      )
    of "BITMAP":
      var hexseq: seq[string]
      while not endOfFile(file):
        let line = file.readLine()
        if line != "ENDCHAR": hexseq.add(line)
        else:
          if code < 0: code = uint16.high.int + code
          result.createGlyph(code.uint16, hexseq, box, dw)
          break

  close(file)

proc destroy(font: BDFFont) =
  for glyph in font.glyphs:
    if glyph != nil: destroy(glyph)

proc createGlyph(font: BDFFont, code: uint16, hexseq: seq[string], box: Rect, dw: int) =
  var bitmap = createRGBSurfaceWithFormat(0, 8, hexseq.len, 32, PIXELFORMAT_RGBA8888)
  
  LOG_SDL lockSurface(bitmap)
  var pixels = cast[ptr uint32](bitmap.pixels)
  for i,hs in hexseq:
    var hex = 0
    discard parseHex(hs, hex)
    for bit in 1..8:
      ptrMath:
        pixels[(bit-1)+i*8] =
          if (hex shr (8-bit) and 1) == 0:
            mapRGBA(bitmap.format, Clear)
          else:
            mapRGBA(bitmap.format, White)
  
  unlockSurface(bitmap)
  
  var glyph = new BDFGlyph
  glyph = BDFGlyph(bitmap: bitmap, box: box, code: code, dwidth: dw)
  font.glyphs[code] = glyph

