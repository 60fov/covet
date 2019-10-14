import sdl2/sdl

import buffermap
import cview
import font
import misc

proc renderDecor*(view: View) =
  LOG_SDL fillRect(view.surface, nil, view.border.color)
  var size = view.border.size
  var rect = Rect(x: size, y: size, w: view.surface.w - (size*2), h: view.surface.h - (size*2))
  LOG_SDL fillRect(view.surface, addr(rect), view.background) 
  
proc render*(view: View, map: BufferMap, font: BDFFont) =
  var glyph: BDFGlyph
  var li = 0
  var w = view.surface.w
  var h = view.surface.h
  var iw = w - (view.inset * 2)
  var ih = h - (view.inset * 2)
  var xcells = int(iw / font.w)
  var ycells = int(ih / font.h)
  while li < ycells:
    li.inc
    var line = map.line(li)
    if line == nil: continue
    var text = line.text
    for ri,c in text:
      glyph = font.glyph(c.uint16)
      if c == ' ': continue
      var left = ri * glyph.dw + glyph.x

      #TODO: line wrap

      var x = view.inset + left
      var y = view.inset + li * font.h - glyph.h - glyph.y
      var dst = Rect(x: x, y: y, w: glyph.w, h: glyph.h)
      LOG_SDL blitSurface(glyph.bitmap, nil, view.surface, dst.addr)