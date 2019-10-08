# Covet
a text editor.  


this is functioning as a make shift design document in it's current capacity.

## Lexical Analysis
after doing *extensive* research I know everything there is to know about lexical anaylisis.
```
Lexer
    identifier (defined while parsing file)
    keyword
        if
        case
        white
        ...
    seperator
        :
        ( )
        { }
        ...
    operator
        +
        <
        =
        ...
    literal
        [0-9]
        " "
        true
        ...
    comment
        #
        ### ###
        ...

```


## Renderer
```
drawChar(font, data, color)
drawLineBuffer(font, data)
drawPageBuffer(font, data)
```

## Data Structures

### Buffer Map Series
a series of buffer maps used for navigating multiple buffers. The buffer maps a represented as a doubly circular linked list
```
Buffer Map Series is a type of ref object
    buffers is a Buffer Map
    current buffer is a Buffer Map
```

### Buffer Map
a map of a buffer represented as a doubly linked list node
```
Buffer Map is a type of ref object
    prev is a Buffer Map
    next is a Buffer Map
    name is a string
    lex map is a Lex Map
    caret is a Position
    line count is an int
    char count is an int
    data is a Line Buffer
    filename is a string
    last sync is a int (time of last read/write)
    modified is a bool
```
Applying polymorphism to the buffer is probably ideal for data efficiency, and "correctness" of representation. A file with few or no line breaks [e.g. licenses, plain text] could be very slow using the line buffer method and isn't how the data is represented "naturally".
```
Buffer Map is a type of ref object
    ...
    data is some Buffer
    ...
    
Buffer is a type of object
    prev is a ref Buffer
    next is a ref Buffer
    data: string (or char array)

Line Buffer is a type of Buffer
Block Buffer is a type of Buffer
(etc.)
```
### Types of Buffers
Currently, I am solely using the line buffer approach, however do plan on implementing the other types of buffers for comparison sake. Also all other buffer types pseudo code will be represented with the polymorphism method, for obvious reasons.
#### Line Buffer
This buffer represented as doubly linked list node of single lines where the data is stored as a gap buffer
```
Line Buffer: type of ref object
    prev: Line Buffer
    next: Line Buffer
    data: string
    gap start: int
    gap end: int

    Constructor, str: string
        copy str -> data
    
```

#### Block Buffer
This Buffer is represented as a block of data (1KiB~4KiB) stored as a gap buffer
```
(TODO)
```

#### Rope Buffer
[wiki](https://en.wikipedia.org/wiki/Rope_(data_structure))
```
(TODO)
```
