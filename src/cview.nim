import sdl2/sdl

import misc

type
  View* = object
    window: Window
    surface*: Surface

proc createView*(): View =
  result.window = createWindow("covet", WindowPosUndefined, WindowPosUndefined, 600, 500, WINDOW_BORDERLESS or WINDOW_SHOWN)
  if result.window == nil: LOG_SDL(1)
  result.surface = getWindowSurface(result.window)
  if result.surface == nil: LOG_SDL(1)

proc refresh*(view: View) {.inline.} = LOG_SDL updateWindowSurface(view.window)

proc destroy*(view: View) =
  destroyWindow(view.window)