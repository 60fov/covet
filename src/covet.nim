import os
import sdl2/sdl
import engine, cview, input, misc, renderer

import font, buffermap

var view: View
var lemon: BDFFont

# VARS
var map: BufferMap

# FUNC DECL
proc init(): bool
proc fin()

proc update(delta: float)

# FUNC IMPLE
proc init(): bool =
  result = true

  view = createView()
  view.setBorder(4, 0xbbff22)
  view.setPadding(25)
  view.background = 0x000000

  lemon = loadBDFFont("res"/"fonts"/"lemon.bdf")
  map = createBufferMap("test")
  map.load("res"/"zen_life.txt")
  
proc fin() =
  destroy(lemon)
  destroy(view)

proc update(delta: float) =

  view.renderDecor()
  view.render(map, lemon)

  refresh(view)

when isMainModule:
  engine.setInitProc(init)
  engine.setFinProc(fin)
  engine.setUpdateProc(update)
  engine.setEventProc(input.handle)
  engine.start()