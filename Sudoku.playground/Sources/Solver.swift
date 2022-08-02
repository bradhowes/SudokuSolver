import Foundation

public enum Sudoku {
  static let size = 9
  static let boxSize = 3
  static let unknown = 0

  public static func solve(board: [[Int]]) -> (board: [[Int]], solved: Bool, unique: Bool) {
    var solver = Solver(board: board)
    let solved = solver.solve()
    var counter = Solver(board: board)
    let count = counter.countAll()
    return (board: solver.board, solved: solved, unique: count == 1)
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
  // The candidate values available for each row
  private var rows: [Set<Int>] = .filled()
  // The candidate values available for each column
  private var columns: [Set<Int>] = .filled()
  // The candidate values available for each box
  private var boxes: [Set<Int>] = .filled()
  // The picked values for each row. The solver iterates over the available values of a row, but the row is evaluated
  // recursively for all open positions so we need to a way to modify the row picks without disturbing the iteration
  // being done elsewhere.
  private var picked: [Set<Int>] = .empty()

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
   This is the entry point into the solver. Note that the solver will always find a solution for non-invalid setups.
   This includes setups that have more than one solution. Currently there is an imprecise check if a board leads to
   multiple solutions.

   - returns: true if unique solution found
   */
  mutating func solve() -> Bool {
    return solve(row: 0, col: 0)
  }

  mutating func countAll() -> Int {
    return countAll(row: 0, col: 0)
  }

  private mutating func solve(row: Int, col: Int) -> Bool {
    // Terminating condition when all rows are done
    guard row < Sudoku.size else { return true }
    // Move to next row if end of columns
    guard col < Sudoku.size else { return solve(row: row + 1, col: 0) }
    // Move to next column if value is known
    guard board[row][col] == Sudoku.unknown else { return solve(row: row, col: col + 1) }

    // Visit all of the unknown values in the row and find the first that leads to a solution.
    for value in rows[row].filter({ !picked[row].contains($0) }) {
      let box = self.boxIndex(row: row, col: col)

      // Only consider candidate if it is also a candidate in the column and box we are working in
      if columns[col].contains(value) && boxes[box].contains(value) {
        pick(value, row: row, col: col, box: box)

        // Recurse to the next column. If true, then the candidate worked.
        if solve(row: row, col: col + 1) {
          return true
        }

        // Candidate did not work -- backtrack by removing it.
        unpick(value, row: row, col: col, box: box)
      }
    }

    return false
  }

  private mutating func countAll(row: Int, col: Int) -> Int {
    // Terminating condition when all rows are done
    guard row < Sudoku.size else { return 1 }
    // Move to next row if end of columns
    guard col < Sudoku.size else { return countAll(row: row + 1, col: 0) }
    // Move to next column if value is known
    guard board[row][col] == Sudoku.unknown else { return countAll(row: row, col: col + 1) }

    // Visit all of the unknown values in the row and try each as a candidate
    var result = 0
    for value in rows[row].filter({ !picked[row].contains($0) }) {
      let box = self.boxIndex(row: row, col: col)

      // Only consider candidate if it is also a candidate in the column and box we are working in
      if columns[col].contains(value) && boxes[box].contains(value) {
        pick(value, row: row, col: col, box: box)

        // Recurse to the next column and record how many solutions were found
        let found = countAll(row: row, col: col + 1)
        result += found

        // Undo all picks before moving to next candidate
        unpick(value, row: row, col: col, box: box)
      }
    }

    return result
  }

  private mutating func pick(_ value: Int, row: Int, col: Int, box: Int) {
    precondition(value >= 1 && value <= Sudoku.size)
    board[row][col] = value
    picked[row].insert(value)
    columns[col].remove(value)
    boxes[box].remove(value)
  }

  private mutating func unpick(_ value: Int, row: Int, col: Int, box: Int) {
    board[row][col] = Sudoku.unknown
    picked[row].remove(value)
    columns[col].insert(value)
    boxes[box].insert(value)
  }

  private func boxIndex(row: Int, col: Int) -> Int {
    row / Sudoku.boxSize * Sudoku.boxSize + col / Sudoku.boxSize
  }
}

