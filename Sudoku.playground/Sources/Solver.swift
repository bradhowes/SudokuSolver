import Foundation

public enum Sudoku {
  static let size = 9
  static let boxSize = 3
  static let unknown = 0

  public static func solve(board: [[Int]]) -> (board: [[Int]], solved: Bool, unique: Bool) {
    let clueCount = board.reduce(0) { $0 + $1.reduce(0) { $0 + ($1 == Sudoku.unknown ? 0 : 1) } }
    var first = Solver(board: board)
    let solved = first.solve(rotation: 0)
    if !solved {
      return (board: first.board, solved: false, unique: false)
    }

    // See if there are other solutions. NOTE this approach can give false results since it does not try all
    // combinations of "picks"
    var maybeUnique = clueCount > 16
    if maybeUnique {
      for rotation in 0..<size {
        var alternative = Solver(board: board)
        let solved = alternative.solve(rotation: rotation)
        if solved && alternative.board != first.board {
          maybeUnique = false
          break
        }
      }
    }
    return (board: first.board, solved: true, unique: maybeUnique)
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
  // The picked values for each row. The intersection of rows and picked should always be empty.
  private var picked: [Set<Int>] = .empty()
  // The candidate values available for each column
  private var columns: [Set<Int>] = .filled()
  // The candidate values available for each box
  private var boxes: [Set<Int>] = .filled()

  init(board: [[Int]]) {
    precondition(board.count == Sudoku.size)
    precondition(board.first(where: {$0.count != Sudoku.size}) == nil)
    self.board = board

    // Initialize the various sets used to track picks for missing numbers.
    for rowIndex in 0..<Sudoku.size {
      for colIndex in 0..<Sudoku.size {
        let value = board[rowIndex][colIndex]
        if value != Sudoku.unknown {
          precondition(value >= 1 && value <= Sudoku.size)

          // Remove value from candidates in various collections
          rows[rowIndex].remove(value)
          columns[colIndex].remove(value)
          boxes[boxIndex(rowIndex: rowIndex, colIndex: colIndex)].remove(value)
        }
      }
    }
  }

  /**
   This is the entry point into the solver. Note that the solver will always find a solution for non-invalid setups.
   This includes setups that have more than one solution. Currently there is an imprecise check if a board leads to
   multiple solutions.

   - parameter rotation rotate initial candidates by this amount to search for alternative solutions
   - returns: true if unique solution found
   */
  mutating func solve(rotation: Int) -> Bool {
    return solve(rowIndex: 0, colIndex: 0, rotation: rotation)
  }

  private func candidates(rowIndex: Int, colIndex: Int, rotation: Int) -> [Int] {
    let unpicked = Array(rows[rowIndex].filter { !picked[rowIndex].contains($0) })
    if rotation == 0 {
      return unpicked
    } else if rotation < unpicked.count {
      return Array(unpicked.dropFirst(rotation) + unpicked.prefix(rotation))
    } else {
      return []
    }
  }

  private mutating func solve(rowIndex: Int, colIndex: Int, rotation: Int = 0) -> Bool {

    // Terminating condition when all rows are done
    guard rowIndex < Sudoku.size else { return true }

    // Move to next row if end of columns
    guard colIndex < Sudoku.size else {
      return solve(rowIndex: rowIndex + 1, colIndex: 0, rotation: rotation)
    }

    // Move to next column if value is known
    guard board[rowIndex][colIndex] == Sudoku.unknown else {
      return solve(rowIndex: rowIndex, colIndex: colIndex + 1, rotation: 0)
    }

    // Visit all of the unknown values in the row and try it out as a candidate
    var result = false
    for value in candidates(rowIndex: rowIndex, colIndex: colIndex, rotation: rotation) {
      let boxIndex = self.boxIndex(rowIndex: rowIndex, colIndex: colIndex)

      // Only consider candidate if it is also a candidate in the column and box we are working in
      if columns[colIndex].contains(value) && boxes[boxIndex].contains(value) {
        pick(value, rowIndex: rowIndex, colIndex: colIndex, boxIndex: boxIndex)

        // Recurse to the next column. If true, then the candidate worked.
        if solve(rowIndex: rowIndex, colIndex: colIndex + 1, rotation: 0) {
          result = true
          break
        } else {

          // Candidate did not work -- backtrack by removing it.
          unpick(value, rowIndex: rowIndex, colIndex: colIndex, boxIndex: boxIndex)
        }
      }
    }
    return result
  }

  private mutating func pick(_ value: Int, rowIndex: Int, colIndex: Int, boxIndex: Int) {
    precondition(value >= 1 && value <= Sudoku.size)
    board[rowIndex][colIndex] = value
    picked[rowIndex].insert(value)
    columns[colIndex].remove(value)
    boxes[boxIndex].remove(value)
  }

  private mutating func unpick(_ value: Int, rowIndex: Int, colIndex: Int, boxIndex: Int) {
    board[rowIndex][colIndex] = Sudoku.unknown
    picked[rowIndex].remove(value)
    columns[colIndex].insert(value)
    boxes[boxIndex].insert(value)
  }

  private func boxIndex(rowIndex: Int, colIndex: Int) -> Int {
    rowIndex / Sudoku.boxSize * Sudoku.boxSize + colIndex / Sudoku.boxSize
  }
}

