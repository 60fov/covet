import sdl2/sdl

import engine

type
  KeyState* = enum
    Active, Pressed, Released, Inactive

var keys: array[int16.high, KeyState]
var prev: array[int16.high, KeyState]

proc handle*(event: Event) =
  case event.kind:
    of Quit: stop()
    of KeyDown:
      var key = event.key.keysym.sym
      if key == K_Escape:
        var e: Event
        e.kind = Quit
        discard pushEvent(e.addr)
      #echo key
    else: discard

