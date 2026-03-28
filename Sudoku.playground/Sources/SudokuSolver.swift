import Foundation

public enum Sudoku {
  static let size = 9
  static let boxSize = 3
  static let unknown = 0

  public static func solve(board: [[Int]], findOne: Bool) -> [[[Int]]] {
    var solver = Solver(board: board, findOne: findOne)
    return solver.solve()
  }
}

private struct Solver {
  // The state of the solution being filled in by the solver.
  private(set) var board: [[Int]]
  // If true, only compute until the first solution is found. Otherwise, find all solutions.
  private let findOne: Bool
  // Collection of solutions found by the solver
  private(set) var solutions = [[[Int]]]()
  // Collection of empty cell locations to find values for
  private var empty: [Cell] = []
  // The candidate values available for each row as a collection of bits
  private var rows: [Int] = .init(repeating: 0, count: Sudoku.size)
  // The candidate values available for each column
  private var columns: [Int] = .init(repeating: 0, count: Sudoku.size)
  // The candidate values available for each box
  private var boxes: [Int] = .init(repeating: 0, count: Sudoku.size)

  /**
   Construct a solver for a given board setup.

   - parameter board: the game board to use
   - parameter findOne: if `true` only find the first solution
   */
  init(board: [[Int]], findOne: Bool) {
    precondition(board.count == Sudoku.size)
    precondition(board.first(where: {$0.count != Sudoku.size}) == nil)

    self.board = board
    self.findOne = findOne

    for row in 0..<Sudoku.size {
      for col in 0..<Sudoku.size {
        let value = board[row][col]
        let cell = Cell(row: row, col: col)
        if value == Sudoku.unknown {
          empty.append(cell)
        } else {
          precondition(value >= 1 && value <= Sudoku.size)
          let bit = 1 << (value - 1)
          rows[cell.row] |= bit
          columns[cell.column] |= bit
          boxes[cell.box] |= bit
        }
      }
    }
  }

  /**
   Locate the cell with the smallest number of candidate values. This is an optimization that should reduce the chance of needing
   to backtrack due to a cell having no available values to pick from. Note that this routine can reorder the contents of the
   `empty` cell collection, so be sure to perform any indexing operations on `empty` after this call.

   This algorithm just loops through the remaining unvisited empty cells to find the next one to fill with a candidate value. It
   might be possible to use some additional book-keeping to reduce the amount of recalculations.

   - parameter emptyIndex: the current empty index being considered
   - returns: the found min available value
   */
  mutating func findMinAvailable(emptyIndex: Int) -> Int {
    var minIndex = emptyIndex
    var minAvailable = 0x1FF

    for index in emptyIndex..<empty.count {
      let cell = empty[index]

      // Obtain the bits that are *not* set in any row, column, or box for the current cell
      let available = ~(rows[cell.row] | columns[cell.column] | boxes[cell.box]) & 0x1FF

      if available.nonzeroBitCount < minAvailable.nonzeroBitCount {
        minAvailable = available
        minIndex = index
      }
    }

    // If we found a better cell to process than the one we are visiting, swap them now so that we will process the current cell
    // sometime in the future.
    if minIndex != emptyIndex {
      empty.swapAt(emptyIndex, minIndex)
    }

    return minAvailable
  }

  /**
   This is the entry point into the solver.

   - returns: array of solutions found
   */
  mutating func solve() -> [[[Int]]] {
    print("Solving...")
    let now = DispatchTime.now()
    solve(emptyIndex: 0)
    let elapsed: Double
    switch now.distance(to: DispatchTime.now()) {
    case .seconds(let s): elapsed = Double(s)
    case .milliseconds(let s): elapsed = Double(s) * 1.0e-3
    case .microseconds(let s): elapsed = Double(s) * 1.0e-6
    case .nanoseconds(let s): elapsed = Double(s) * 1.0e-9
    case .never: elapsed = 0.0
    @unknown default: elapsed = -1.0
    }
    print(String(format: "...done in %.6f seconds", elapsed))
    return solutions
  }

  private mutating func solve(emptyIndex: Int) {
    if emptyIndex == empty.count {
      solutions.append(board)
      return
    }

    // NOTE: order is important here since `findMinAvailable` can reorder the `empty` array.
    var available = findMinAvailable(emptyIndex: emptyIndex)
    let cell = empty[emptyIndex]

    while available > 0 {
      let bit = available & -available
      available &= ~bit
      let digit = bit.trailingZeroBitCount + 1

      board[cell] = digit
      rows[cell.row] |= bit
      columns[cell.column] |= bit
      boxes[cell.box] |= bit

      solve(emptyIndex: emptyIndex + 1)
      if findOne && !solutions.isEmpty { break }

      board[cell] = Sudoku.unknown
      rows[cell.row] &= ~bit
      columns[cell.column] &= ~bit
      boxes[cell.box] &= ~bit
    }
  }
}

private struct Cell {
  let row: Int
  let column: Int
  let box: Int

  init(row: Int, col: Int) {
    self.row = row
    self.column = col
    self.box = (row / Sudoku.boxSize) * Sudoku.boxSize + (col / Sudoku.boxSize)
  }
}

private extension Array where Element == Array<Int> {
  subscript(_ cell: Cell) -> Int {
    get {
      self[cell.row][cell.column]
    }
    set {
      self[cell.row][cell.column] = newValue
    }
  }
}

