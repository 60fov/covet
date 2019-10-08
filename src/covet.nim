import os
import sdl2/sdl
import engine, cview, input, misc

import font

var view: View
var lemon: BDFFont

#FUNC DECL
proc init(): bool
proc fin()

proc update(delta: float)

# FUNC IMPLE
proc init(): bool =
  result = true
  view = createView()
  lemon = loadBDFFont("res"/"fonts"/"lemon.bdf")

proc fin() =
  destroy(lemon)
  destroy(view)

proc update(delta: float) =
  var glyph = lemon.glyph('a'.uint16)
  var dst = Rect(x: 100,y: 100, w: glyph.w, h: glyph.h)
  LOG_SDL blitSurface(glyph.bitmap, nil, view.surface, dst.addr)
  refresh(view)

when isMainModule:
  engine.setInitProc(init)
  engine.setFinProc(fin)
  engine.setUpdateProc(update)
  engine.setEventProc(input.handle)
  engine.start()