import Foundation

public enum Sudoku {}

extension Sudoku {
  static let size = 9
  static let boxSize = 3
  static let unknown = 0

  public static func solve(board: [[Int]]) -> [[Int]] {
    var solver = Solver(board: board)
    solver.solve()
    return solver.board
  }
}

extension Set where Element == Int {
  static func filled() -> Set { .init([1, 2, 3, 4, 5, 6, 7, 8, 9]) }
}

extension Array where Element == Set<Int> {
  static func filled() -> [Set<Int>] { .init(repeating: .filled(), count: Sudoku.size) }
  static func empty() -> [Set<Int>] { .init(repeating: .init(), count: Sudoku.size) }
}

struct Solver {

  private(set) var board: [[Int]]
  private var rows: [Set<Int>] = .filled()
  private var columns: [Set<Int>] = .filled()
  private var boxes: [Set<Int>] = .filled()
  private var picked: [Set<Int>] = .empty()

  init(board: [[Int]]) {
    precondition(board.count == Sudoku.size)
    precondition(board.first(where: {$0.count != Sudoku.size}) == nil)
    self.board = board
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

  mutating func solve() {
    _ = solve(rowIndex: 0, colIndex: 0)
    // We should not have any 0 entries in our board if it was solved properly
    precondition(board.first(where: {$0.first(where: {$0 == Sudoku.unknown}) != nil}) == nil)
  }

  private mutating func solve(rowIndex: Int, colIndex: Int) -> Bool {

    // Terminating condition when all rows are done
    guard rowIndex < Sudoku.size else { return true }
    // Move to next row if end of columns
    guard colIndex < Sudoku.size else { return solve(rowIndex: rowIndex + 1, colIndex: 0) }
    // Move to next column if value is known
    guard board[rowIndex][colIndex] == Sudoku.unknown else { return solve(rowIndex: rowIndex, colIndex: colIndex + 1) }

    // Visit all of the unknown values in the row and try it out as a candidate
    var result = false
    for value in rows[rowIndex] where !picked[rowIndex].contains(value) {
      let boxIndex = self.boxIndex(rowIndex: rowIndex, colIndex: colIndex)

      // Only consider candidate if it is also a candidate in the column and box we are working in
      if columns[colIndex].contains(value) && boxes[boxIndex].contains(value) {
        pick(value, rowIndex: rowIndex, colIndex: colIndex, boxIndex: boxIndex)

        // Recurse to the next column. If true, then the candidate worked.
        if solve(rowIndex: rowIndex, colIndex: colIndex + 1) {
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

