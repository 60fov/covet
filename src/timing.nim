import sdl2/sdl

#TYPE:decl
type
  TimePrecision = enum
    base=1, milli=1_000, micro=1_000_000

type
  Rate* = tuple
    time: float
    ndt: float #normalized delta time
    adt: float #accumulated delta time 
    count: int
    last: float


#PROC:decl
proc sysfreq*(): uint64
proc syscount*(): uint64
proc time*(precision: TimePrecision = base): float

proc rate*(rate: float): Rate
proc deltaTime*(rate: float): float

#PROC:impl
proc syscount*(): uint64 =
  return getPerformanceCounter()

proc sysfreq*(): uint64 = 
  return getPerformanceFrequency()

proc time*(precision: TimePrecision = base): float =
  return float(syscount()) / float(sysfreq()) * float(ord(precision))



proc rate*(rate: float): Rate =
  result.time = deltaTime(rate)
  result.last = time()

proc limit*(rate: var Rate, function: proc(d: float = 0)) =
  var now = time()
  var delta = now - rate.last
  rate.last = now
  rate.adt += delta
  rate.ndt += delta / rate.time
  if rate.ndt >= 1:
    function(rate.adt)
    rate.adt = 0
    rate.ndt -= 1
    rate.count += 1

proc deltaTime(rate: float): float =
  if rate <= 0: return 0
  return 1 / rate