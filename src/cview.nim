import sdl2/sdl

import misc

type
  View* = object
    window: Window
    surface: Surface
    renderer: Renderer

proc createView*(): View =
  result.window = createWindow("covet", WindowPosUndefined, WindowPosUndefined, 600, 500, WINDOW_BORDERLESS or WINDOW_SHOWN)
  if result.window == nil: LOG_SDL(1)
  result.surface = getWindowSurface(result.window)
  if result.surface == nil: LOG_SDL(1)
  result.renderer = createRenderer(result.window, -1, RENDERER_ACCELERATED)
  if result.renderer == nil: LOG_SDL(1)

proc refresh*(view: View) {.inline.} = renderPresent(view.renderer)

proc destroy*(view: View) =
  destroyRenderer(view.renderer)
  destroyWindow(view.window)