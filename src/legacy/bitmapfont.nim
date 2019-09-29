import 
  sdl2/sdl,
  sdl2/sdl_image

import
  ospaths,
  os,
  macros,
  strutils,
  parseutils

import
  util/misc

let Clear = Color(r: 0, g: 0, b: 0, a: 0)
let White = Color(r: 255, g: 255, b: 255, a: 255)

#TYPE DECL
type
  Glyph* = ref object
    bitmap: Surface
    box: Rect
    code: uint16
    dwidth: int

  BitmapFont* = ref object
    glyphs: array[0..uint16.high.int, Glyph]
    name: string
    descent: int
    ascent: int
    box: Rect
    color: Color


#FUNC DECL
proc `bitmap=`*(g: var Glyph, bitmap: Surface) {.inline.} = g.bitmap = bitmap
proc bitmap*(g: Glyph): Surface {.inline.} = g.bitmap
proc box*(g: Glyph): Rect {.inline.} = g.box
proc code*(g: Glyph): uint16 {.inline.} = g.code
proc dwidth*(g: Glyph): int {.inline.} = g.dwidth

proc name*(font: BitmapFont): string {.inline.} = font.name
proc getGlyph*(font: BitmapFont, index: uint16): Glyph {.inline.} = font.glyphs[index]
proc box*(font: BitmapFont): Rect {.inline.} = font.box

proc drawGlyph*(glyph: Glyph, surface: Surface, x, y: int)

proc loadBitmapFont*(path: string): BitmapFont
proc destroy*(font: BitmapFont)

proc printSurfPixels(surf: Surface, w, h: int)
proc createBitmap(hexseq: seq[string], color = White, print: bool = false): Surface


#FUNC IMPLE
proc printSurfPixels(surf: Surface, w, h: int) =
  let pixels = cast[ptr uint32](surf.pixels)
  for y in 0..<h:
    for x in 0..<w:
      ptrMath:
        var color = getRGB(pixels[x+y*8], surf.format)

proc createBitmap(hexseq: seq[string], color: Color, print: bool): Surface =
  var hex = 0
  result = createRGBSurfaceWithFormat(0, 8, hexseq.len, 32, PIXELFORMAT_RGBA8888)
  LOG_SDL lockSurface(result)
  var pixels = cast[ptr uint32](result.pixels)
  for index,hexstr in hexseq:
    discard parseHex(hexstr, hex)
    for bit in 1..8:
      ptrMath: pixels[(bit-1)+index*8] = 
        if (hex shr (8-bit) and 1) == 0:
          mapRGBA(result.format, Clear)
        else: 
          mapRGBA(result.format, color)

  if print: printSurfPixels(result, 8, hexseq.len)
  unlockSurface(result)

proc loadBitmapFont(path: string): BitmapFont =
  result = BitmapFont()
  if result.color == Color(): result.color = White
  let file = open(path)
  var glyph: Glyph
  while not endOfFile(file):
    #data processing
    let line = file.readLine()
    var data = line.split()
    for i,d in data: data[i] = d.multiReplace(("\"", ""))
    case data[0]
    of "FONTBOUNDINGBOX":
      result.box = 
        Rect(
          w:data[1].parseInt,
          h:data[2].parseInt,
          x:data[3].parseInt,
          y:data[4].parseInt
        )
    of "FACE_NAME": 
      result.name = data[1]
    of "FONT_DESCENT":
      result.descent = parseInt(data[1])
    of "FONT_ACSENT":
      result.ascent = parseInt(data[1])
    of "ENCODING":
      glyph = Glyph(code: parseInt(data[1]).uint16, bitmap: nil, box: Rect())
    of "DWIDTH":
      glyph.dwidth = parseInt(data[1])
    of "BBX":
      glyph.box = 
        Rect(
          w:data[1].parseInt,
          h:data[2].parseInt,
          x:data[3].parseInt,
          y:data[4].parseInt
        )
    of "BITMAP":
      var hexseq: seq[string]
      while not endOfFile(file):
        let line = file.readLine()
        if line == "ENDCHAR":
          glyph.bitmap = createBitmap(hexseq, White, false)
          result.glyphs[glyph.code] = glyph
          break
        else: 
          hexseq.add(line)
  
  close(file)

proc drawGlyph(glyph: Glyph, surface: Surface, x, y: int) = 
  var dst = Rect(x: x+glyph.box.x, y: y+glyph.box.y) 
  unlockSurface(surface)
  LOG_SDL blitSurface(glyph.bitmap, nil, surface, addr(dst))

proc destroy(font: BitmapFont) = 
  for glyph in font.glyphs:
    if glyph != nil and glyph.bitmap != nil:
      free(glyph.bitmap)