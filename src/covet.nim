import sdl2/sdl

import engine, cview, timing, input, misc

var view: View

#FUNC DECL
proc init(): bool
proc fin()

proc update(delta: float)

# FUNC IMPLE
proc init(): bool =
  result = true
  view = createView()

proc fin() =
  destroy(view)

proc update(delta: float) =
  refresh(view)

when isMainModule:
  engine.setInitProc(init)
  engine.setFinProc(fin)
  engine.setUpdateProc(update)
  engine.setEventProc(input.handle)
  engine.start()
