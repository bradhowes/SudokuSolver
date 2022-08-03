import UIKit
import PlaygroundSupport
import CoreGraphics

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

class MyViewController : UIViewController {

  var mainView: UIStackView!
  var prevPuzzleButton: UIButton!
  var puzzleTitle: UILabel!
  var nextPuzzleButton: UIButton!
  var puzzleView: UIStackView?
  var puzzleViewBackgroundView: UIView?
  var solutionState: UILabel!
  var prevSolutionButton: UIButton!
  var nextSolutionButton: UIButton!

  let puzzles = [easy, diabolical, multiple, multiple2, unsolvable]
  let names = ["Easy", "Diabolical", "Multiple", "Multiple 2", "Unsolvable"]
  var puzzleIndex = 0
  var solutions: [[[Int]]] = []
  var solutionIndex = 0

  let prevButtonText = "◀"
  let nextButtonText = "▶"

  private func pinBackground(_ view: UIView, to stackView: UIStackView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    stackView.insertSubview(view, at: 0)
    view.pin(to: stackView, border: 4)
  }

  override func loadView() {
    let view = UIView()
    view.backgroundColor = .systemBackground
    self.view = view
    makeMainView()
    showPuzzle()
  }

  private func makeMainView() {
    mainView = UIStackView()
    mainView.axis = .vertical
    mainView.distribution = .equalSpacing
    mainView.spacing = 8
    mainView.translatesAutoresizingMaskIntoConstraints = false
    view.addCenteredSubview(mainView)

    makeTitle()
    makeStatus()
  }

  private func makeTitle() {
    let topRow = UIStackView()
    topRow.axis = .horizontal
    topRow.distribution = .fillEqually
    topRow.spacing = 4

    prevPuzzleButton = UIButton(type: .system)
    prevPuzzleButton.setTitle(prevButtonText, for: .normal)
    prevPuzzleButton.addTarget(self, action: #selector(previousPuzzle), for: .touchDown)
    topRow.addArrangedSubview(prevPuzzleButton)

    puzzleTitle = UILabel()
    puzzleTitle.font = .systemFont(ofSize: 18)
    puzzleTitle.backgroundColor = .white
    puzzleTitle.textAlignment = .center
    puzzleTitle.text = ""
    puzzleTitle.textColor = .black
    topRow.addArrangedSubview(puzzleTitle)

    nextPuzzleButton = UIButton(type: .system)
    nextPuzzleButton.setTitle(nextButtonText, for: .normal)
    nextPuzzleButton.addTarget(self, action: #selector(nextPuzzle), for: .touchDown)
    topRow.addArrangedSubview(nextPuzzleButton)

    mainView.addArrangedSubview(topRow)
  }

  private func makeStatus() {
    let statusRow = UIStackView()
    statusRow.axis = .horizontal
    statusRow.distribution = .fillEqually
    statusRow.spacing = 4

    prevSolutionButton = UIButton(type: .system)
    prevSolutionButton.setTitle(prevButtonText, for: .normal)
    prevSolutionButton.addTarget(self, action: #selector(previousSolution), for: .touchDown)
    statusRow.addArrangedSubview(prevSolutionButton)

    solutionState = UILabel()
    solutionState.font = .systemFont(ofSize: 18)
    solutionState.text = "Unknown"
    solutionState.textAlignment = .center
    solutionState.textColor = .systemRed
    statusRow.addArrangedSubview(solutionState)

    nextSolutionButton = UIButton(type: .system)
    nextSolutionButton.setTitle(nextButtonText, for: .normal)
    nextSolutionButton.addTarget(self, action: #selector(nextSolution), for: .touchDown)
    statusRow.addArrangedSubview(nextSolutionButton)

    mainView.addArrangedSubview(statusRow)
  }

  func decode(_ encoded: String) -> [[Int]] {
    precondition(encoded.count == 9 * 9)
    return stride(from: 0, to: encoded.count, by: 9).map {
      let start = encoded.index(encoded.startIndex, offsetBy: $0)
      let end = encoded.index(start, offsetBy: 9)
      return encoded[start..<end].map { Int(String($0)) ?? 0 }
    }
  }

  func showPuzzle() {

    puzzleTitle.text = names[puzzleIndex]
    let puzzle = decode(puzzles[puzzleIndex])
    solutions = Sudoku.solve(board: puzzle)
    solutionIndex = 0

    showSolution()
  }

  func showSolution() {

    puzzleView?.removeFromSuperview()
    puzzleViewBackgroundView?.removeFromSuperview()

    puzzleViewBackgroundView = UIView()
    puzzleViewBackgroundView?.backgroundColor = .black

    let puzzle = decode(puzzles[puzzleIndex])
    let puzzleView = SolutionViewBuilder.buildFrom(config: puzzle, solution: solutions.isEmpty ? nil : solutions[solutionIndex])
    self.puzzleView = puzzleView

    pinBackground(puzzleViewBackgroundView!, to: puzzleView)
    mainView.insertArrangedSubview(puzzleView, at: 1)

    switch solutions.count {
    case 0:
      solutionState.text = "Unsolvable"
      solutionState.textColor = .systemRed
      break

    case 1:
      solutionState.text = "Unique"
      solutionState.textColor = .systemGreen

    default:
      solutionState.text = "\(solutionIndex + 1) of \(solutions.count)"
      solutionState.textColor = .systemYellow
    }

    prevSolutionButton.isEnabled = solutions.count > 1
    nextSolutionButton.isEnabled = solutions.count > 1

    view.setNeedsLayout()
  }

  func addButtons() -> UIStackView {
    let row = UIStackView()
    row.backgroundColor = .white
    row.axis = .horizontal
    row.distribution = .fillEqually
    row.spacing = 8
    row.translatesAutoresizingMaskIntoConstraints = false

    return row
  }

  @objc func previousPuzzle(sender: UIButton) {
    puzzleIndex = (puzzleIndex == 0 ? puzzles.count : puzzleIndex) - 1
    showPuzzle()
  }

  @objc func nextPuzzle(sender: UIButton) {
    puzzleIndex = (puzzleIndex == puzzles.count - 1 ? -1 : puzzleIndex) + 1
    showPuzzle()
  }

  @objc func previousSolution(sender: UIButton) {
    solutionIndex = (solutionIndex == 0 ? solutions.count : solutionIndex) - 1
    showSolution()
  }

  @objc func nextSolution(sender: UIButton) {
    solutionIndex = (solutionIndex == solutions.count - 1 ? -1 : solutionIndex) + 1
    showSolution()
  }
}

extension UIView {

  func addCenteredSubview(_ child: UIView) {
    addSubview(child)
    let dict = ["view": self, "child": child]
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:[view]-(<=1)-[child]-(<=1)-[view]", options: .alignAllCenterX, metrics: nil, views: dict) +
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:[view]-(<=1)-[child]-(<=1)-[view]", options: .alignAllCenterY, metrics: nil, views: dict)
    )
  }

  func pin(to view: UIView, border: CGFloat) {
    let constraints = [
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topAnchor.constraint(equalTo: view.topAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]

    for each in constraints {
      if each.secondAnchor == view.leadingAnchor || each.secondAnchor == view.topAnchor {
        each.constant = -border
      }
      else {
        each.constant = border
      }
    }

    NSLayoutConstraint.activate(constraints)
  }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
