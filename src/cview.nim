import sdl2/sdl

import misc

type
  View* = object
    window: Window
    surface*: Surface
    rows, columns: int
    padding: int
    border: tuple[size: int, color: uint32]
    background*: uint32

proc createView*(): View =
  result.window = createWindow("covet", WindowPosUndefined, WindowPosUndefined, 600, 500, WINDOW_BORDERLESS or WINDOW_SHOWN)
  if result.window == nil: LOG_SDL(1)
  result.surface = getWindowSurface(result.window)
  if result.surface == nil: LOG_SDL(1)

proc border*(view: View): tuple[size: int, color: uint32] = view.border
proc padding*(view: View): int = view.padding
proc inset*(view: View): int = view.border.size + view.padding

proc setBorder*(view: var View, size: int, color: uint32) = view.border = (size, color)
proc setPadding*(view: var View, size: int) = view.padding = size

proc refresh*(view: View) {.inline.} = LOG_SDL updateWindowSurface(view.window)

proc destroy*(view: View) =
  destroyWindow(view.window)