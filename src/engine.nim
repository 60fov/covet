import sugar
import sdl2/sdl
import timing, misc

const DefInitFlags: uint32 = INIT_VIDEO or INIT_EVENTS or INIT_EVERYTHING

var running: bool
var tickrate: Rate = rate(60)
var initproc: () -> bool
var finproc: () -> void
var updateproc: (float) -> void
var eventproc: (Event) -> void

proc start*()
proc stop*() {.inline.} = running = false

proc setTickRate*(rate: Rate) {.inline.} = tickrate = rate
proc setInitProc*(init: () -> bool) {.inline.} = initproc = init
proc setFinProc*(fin: () -> void) {.inline.} = finproc = fin
proc setUpdateProc*(up: (float) -> void) {.inline.} = updateproc = up
proc setEventProc*(eh: (Event) -> void) {.inline.} = eventproc = eh

proc init(initflags = DefInitFlags): bool
proc fin()

proc run()

proc start() =
  if initproc == nil: echo "init procedure unset!"
  if finproc == nil: echo "fin procedure unset!"
  if updateproc == nil: echo "update procedure unset!"
  if eventproc == nil: echo "event procedure unset!"
  if init(): running = true
  run()
  
proc init(initflags: uint32): bool =
  if sdl.init(initflags) != 0:
    LOG_SDL(-1)
    return false

  return initproc()

proc fin() =
  finproc()
  sdl.quit()

proc run() =
  var event: Event
  while running:
    LOG_SDL waitEvent(event.addr)
    eventproc(event)
    updateproc(0) #TODO: remove delta
  fin()
