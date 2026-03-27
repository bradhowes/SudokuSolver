import PlaygroundSupport
import CoreGraphics
import SwiftUI

let medium =
"53  7    " +
"6  195   " +
" 98    6 " +
"8   6   3" +
"4  8 3  1" +
"7   2   6" +
" 6    28 " +
"   419  5" +
"    8  79"

let easy =
"  79  281" +
"628  3 9 " +
"4 9     6" +
"7  6 9832" +
"1 3      " +
"8       9" +
"  6378 2 " +
" 8 49167 " +
" 71 2694 "

let diabolical =
"    9 16 " +
"63  2    " +
" 2       " +
"  26     " +
"4  1 5  3" +
"17       " +
"9    4  6" +
"     78 4" +
"  3    2 "

let multiple =
"  6 7 4 3" +
"   4  2  " +
" 7  23 1 " +
"5     1  " +
" 4 2 8 6 " +
"  3     5" +
" 3 7   5 " +
"  7  5   " +
"4 5 1 7  "

let multiple2 =
"926571483" +
"351486279" +
"874923516" +
"582367194" +
"149258367" +
"7631  825" +
"2387  651" +
"617835942" +
"495712738"

let unsolvable =
"3 79  281" +
"628  3 9 " +
"4 9     6" +
"7  6 9832" +
"1 3      " +
"8       9" +
"  6378 2 " +
" 8 49167 " +
" 71 2694 "

struct SudokuView: View {
  @StateObject private var viewModel = SudokuViewModel()

  private var solutionStatusText: String {
    switch viewModel.solutions.count {
    case 0:
      return "Unsolvable"
    case 1:
      return "Unique"
    default:
      return "\(viewModel.solutionIndex + 1) of \(viewModel.solutions.count)"
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 4) {
        Button {
          viewModel.previousPuzzle()
        } label: {
          Text("◀")
        }
        .disabled(viewModel.puzzles.isEmpty)

        Text(viewModel.names[viewModel.puzzleIndex])
          .font(.system(size: 18))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(Color.white)
          .foregroundColor(.black)

        Button {
          viewModel.nextPuzzle()
        } label: {
          Text("▶")
        }
        .disabled(viewModel.puzzles.isEmpty)
      }

      SudokuPuzzleView(
        board: viewModel.puzzles[viewModel.puzzleIndex],
        solution: viewModel.solutions.isEmpty ? viewModel.puzzles[viewModel.puzzleIndex] : viewModel.solutions[viewModel.solutionIndex]
      )

      HStack(spacing: 4) {
        Button {
          viewModel.previousSolution()
        } label: {
          Text("◀")
        }
        .disabled(viewModel.solutions.isEmpty)

        Text(viewModel.solutionStatusText)
          .font(.system(size: 18))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .foregroundColor(solutionStatusColor)

        Button {
          viewModel.nextSolution()
        } label: {
          Text("▶")
        }
        .disabled(viewModel.solutions.isEmpty)
      }
    }
    .animation(.smooth, value: viewModel.puzzleIndex)
    .animation(.smooth, value: viewModel.solutionIndex)
    .padding()
  }

  var solutionStatusColor: Color {
    switch viewModel.solutions.count {
    case 0:
      return .red
    case 1:
      return .green
    default:
      return .yellow
    }
  }
}

struct SudokuPuzzleView: View {
  let board: [[Int]]
  let solution: [[Int]]
  let cellSize: CGFloat = 40

  var body: some View {
    VStack(spacing: 0) {
      ForEach(0..<9, id: \.self) { row in
        HStack(spacing: 0) {
          ForEach(0..<9, id: \.self) { col in
            CellView(value: solution[row][col], color: board[row][col] == 0 ? .green : .black)
              .frame(width: cellSize, height: cellSize)
              .background(.white)
              .border(Color.black, width: 0.5)
              .padding(.leading, (col % 3) == 0 ? 2 : 0)
          }
        }
        // .padding(.horizontal, 2)
        .padding(.top, (row % 3) == 0 ? 2 : 0)
      }
    }
    .padding(.trailing, 2)
    .padding(.bottom, 2)
    .background(.black)
  }
}

struct CellView: View {
  let value: Int
  let color: Color

  var body: some View {
    Text(value == 0 ? "?" : String(value))
      .font(.system(size: 18, weight: .semibold))
      .foregroundColor(color)
  }
}

class SudokuViewModel: ObservableObject {
  @Published var puzzleIndex = 0
  @Published var solutionIndex = 0
  @Published var solutions: [[[Int]]] = []

  let puzzles = [easy, medium, diabolical, multiple, multiple2, unsolvable].map { decode($0) }
  let names = ["Easy", "Medium", "Diabolical", "Multiple", "Multiple 2", "Unsolvable"]

  static func decode(_ encoded: String) -> [[Int]] {
    precondition(encoded.count == 9 * 9)
    return stride(from: 0, to: encoded.count, by: 9).map {
      let start = encoded.index(encoded.startIndex, offsetBy: $0)
      let end = encoded.index(start, offsetBy: 9)
      return encoded[start..<end].map { Int(String($0)) ?? 0 }
    }
  }

  var currentPuzzleName: String { names[puzzleIndex] }

  var solutionStatusText: String {
    switch solutions.count {
    case 0:
      return "Unsolvable"
    case 1:
      return "Unique"
    default:
      return "\(solutionIndex + 1) of \(solutions.count)"
    }
  }

  var solutionStatusColor: Color {
    switch solutions.count {
    case 0:
      return .red
    case 1:
      return .green
    default:
      return .yellow
    }
  }

  init() {
    solvePuzzle()
  }

  func previousPuzzle() {
    if puzzleIndex == 0 {
      puzzleIndex = puzzles.count - 1
    } else {
      puzzleIndex -= 1
    }
    solvePuzzle()
  }

  func nextPuzzle() {
    if puzzleIndex == puzzles.count - 1 {
      puzzleIndex = 0
    } else {
      puzzleIndex += 1
    }
    solvePuzzle()
  }

  func previousSolution() {
    if solutionIndex == 0 {
      solutionIndex = solutions.count - 1
    } else {
      solutionIndex -= 1
    }
  }

  func nextSolution() {
    if solutionIndex == solutions.count - 1 {
      solutionIndex = 0
    } else {
      solutionIndex += 1
    }
  }

  private func solvePuzzle() {
    solutions = Sudoku.solve(board: puzzles[puzzleIndex], findOne: false)
    solutionIndex = 0
  }
}

PlaygroundPage.current.setLiveView(
  SudokuView()
    .previewLayout(.fixed(width: 500, height: 800))
)
