import Foundation

public enum Sudoku {
  static let size = 9
  static let boxSize = 3
  static let unknown = 0

  public static func solve(board: [[Int]]) -> [[[Int]]] {
    var solver = Solver(board: board)
    return solver.solve()
  }
}

fileprivate extension Set where Element == Int {
  static func filled() -> Set { .init([1, 2, 3, 4, 5, 6, 7, 8, 9]) }
}

fileprivate extension Array where Element == Set<Int> {
  static func filled() -> [Set<Int>] { .init(repeating: .filled(), count: Sudoku.size) }
  static func empty() -> [Set<Int>] { .init(repeating: .init(), count: Sudoku.size) }
}

fileprivate struct Solver {
  // The state of the solution being filled in by the solver
  private(set) var board: [[Int]]
  // Set to the first solution found by the solver
  private(set) var solutions = [[[Int]]]()
  // The candidate values available for each row
  private var rows: [Set<Int>] = .filled()
  // The candidate values available for each column
  private var columns: [Set<Int>] = .filled()
  // The candidate values available for each box
  private var boxes: [Set<Int>] = .filled()

  init(board: [[Int]]) {
    precondition(board.count == Sudoku.size)
    precondition(board.first(where: {$0.count != Sudoku.size}) == nil)
    self.board = board

    // Initialize the various sets used to track picks for missing numbers.
    for row in 0..<Sudoku.size {
      for col in 0..<Sudoku.size {
        let value = board[row][col]
        if value != Sudoku.unknown {
          precondition(value >= 1 && value <= Sudoku.size)
          // Remove value from candidates in various collections
          rows[row].remove(value)
          columns[col].remove(value)
          boxes[boxIndex(row: row, col: col)].remove(value)
        }
      }
    }
  }

  /**
   This is the entry point into the solver.

   - returns: array of solutions found
   */
  mutating func solve() -> [[[Int]]] {
    solve(row: 0, col: 0)
    return solutions
  }

  private mutating func solve(row: Int, col: Int) {
    if row == Sudoku.size {
      solutions.append(board)
    }
    else if col == Sudoku.size {
      solve(row: row + 1, col: 0)
    }
    else if board[row][col] != Sudoku.unknown {
      solve(row: row, col: col + 1)
    }
    else {
      for value in rows[row] {
        let box = self.boxIndex(row: row, col: col)

        // Only consider candidate if it is also a candidate in the column and box we are working in
        if columns[col].contains(value) && boxes[box].contains(value) {
          pick(value, row: row, col: col, box: box)

          // Recurse to the next column and record how many solutions were found
          solve(row: row, col: col + 1)

          // Undo all picks before moving to next candidate
          unpick(value, row: row, col: col, box: box)
        }
      }
    }
  }

  private mutating func pick(_ value: Int, row: Int, col: Int, box: Int) {
    board[row][col] = value
    rows[row].remove(value)
    columns[col].remove(value)
    boxes[box].remove(value)
  }

  private mutating func unpick(_ value: Int, row: Int, col: Int, box: Int) {
    board[row][col] = Sudoku.unknown
    rows[row].insert(value)
    columns[col].insert(value)
    boxes[box].insert(value)
  }

  private func boxIndex(row: Int, col: Int) -> Int {
    row / Sudoku.boxSize * Sudoku.boxSize + col / Sudoku.boxSize
  }
}
