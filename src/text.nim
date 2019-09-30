import listsv

type
  Line = ref object
    data: string
    gs: int
    ge: int

  Location = ref object
    line: LinkedList[Line]
    pos: int
  
  TextFile = ref object 
    lines: LinkedList[Line]