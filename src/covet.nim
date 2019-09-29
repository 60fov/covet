import sdl2/sdl

import cview, timing, misc

var running: bool

var view: View
var tickrate: Rate

#FUNC DECL
proc init(): bool
proc fin()
proc stop() {.inline.} = running = false 

proc handleEvents()
proc update(delta: float)

proc run()

# FUNC IMPLE
proc init(): bool = 
  LOG_SDL init(INIT_EVENTS or INIT_VIDEO)

  view = createView()
  tickrate = rate(40)
  return true

proc fin() = 
  destroy(view)
  sdl.quit()

proc handleEvents() = 
  var event: Event
  while pollEvent(event.addr) != 0:
    case event.kind:
      of Quit: stop()
      of KeyDown: 
        if event.key.keysym.sym == K_ESCAPE: stop()
      else: discard

proc update(delta: float) =
  refresh(view)

proc run() =
  running = true
  while running:
    handleEvents()
    tickrate.limit(update)
  fin()

when isMainModule:
  if init(): run()