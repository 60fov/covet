import macros

macro LOG_SDL*(p: untyped): untyped =
  nnkStmtList.newTree(
    nnkIfStmt.newTree(
      nnkElifBranch.newTree(
        nnkInfix.newTree(
          newIdentNode("!="),
          p,
          newLit(0)
        ),
        nnkStmtList.newTree(
          nnkCommand.newTree(
            newIdentNode("echo"),
            nnkCall.newTree(
              nnkDotExpr.newTree(
                newIdentNode("sdl"),
                newIdentNode("getError")
              )
            )
          )
        )
      )
    )
  )