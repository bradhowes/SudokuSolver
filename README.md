# Sudoku Solver

Simple Swift playground that shows the solution (if it exists) to a Sudoku puzzle.

![](solution.png)

The puzzle is defined using an array of arrays of `Int` values with `0` values indicating unknown values. Here is the configuration for a very hard
puzzle (shown above).

```swift
let puzzle = [
  [0, 0, 0, 0, 9, 0, 1, 6, 0],
  [6, 3, 0, 0, 2, 0, 0, 0, 0],
  [0, 2, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 2, 6, 0, 0, 0, 0, 0],
  [4, 0, 0, 1, 0, 5, 0, 0, 3],
  [1, 7, 0, 0, 0, 0, 0, 0, 0],
  [9, 0, 0, 0, 0, 4, 0, 0, 6],
  [0, 0, 0, 0, 0, 7, 8, 0, 4],
  [0, 0, 3, 0, 0, 0, 0, 2, 0]
]
```

Alternatively, one can provide a string of 81 characters, where spaces indicate a missing value:

```swift
let puzzle =
  "    9 16 " +
  "63  2    " +
  " 2       " +
  "  26     " +
  "4  1 5  3" +
  "17       " +
  "9    4  6" +
  "     78 4" +
  "  3    2 "
```

Getting a solution from the first form:

```swift
let solved = Sudoku.solve(board: puzzle)
```

Getting a solution from the string form:

```swift
let solved = Sudoku.solve(board: decode(puzzle))
```

The playground shows the solution in green and the original puzzle values in white. Cycle thru different puzzles with the "◀" and "▶" at the top.
if a puzzle has multiple solutions, use the "◀" and "▶" at the bottom to cycle through them.
