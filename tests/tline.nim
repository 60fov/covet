import line

line.GapSize = 8

var pos = 5
var lb = createLineBuffer("goodbye world")
echo lb

lb.insertAt('a', pos)
inc(pos)
echo lb

lb.insertAt('b', pos)
inc(pos)
lb.insertAt('1', pos)
inc(pos)
lb.insertAt('2', pos)
inc(pos)
lb.insertAt('3', pos)
inc(pos)
lb.insertAt('4', pos)
inc(pos)
lb.insertAt('5', pos)
inc(pos)
echo lb
lb.insertAt('6', pos)
inc(pos)
echo lb
lb.insertAt('7', pos)
inc(pos)
echo lb
