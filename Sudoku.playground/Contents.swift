//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

let easy = [
  [0, 0, 7, 9, 0, 0, 2, 8, 1],
  [6, 2, 8, 0, 0, 3, 0, 9, 0],
  [4, 0, 9, 0, 0, 0, 0, 0, 6],
  [7, 0, 0, 6, 0, 9, 8, 3, 2],
  [1, 0, 3, 0, 0, 0, 0, 0, 0],
  [8, 0, 0, 0, 0, 0, 0, 0, 9],
  [0, 0, 6, 3, 7, 8, 0, 2, 0],
  [0, 8, 0, 4, 9, 1, 6, 7, 0],
  [0, 7, 1, 0, 2, 6, 9, 4, 0]
]

let diabolical = [
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

let config = diabolical
let solved = Sudoku.solve(board: config)

class MyViewController : UIViewController {
  override func loadView() {
    let view = UIView()
    view.backgroundColor = .white

    let rows = UIStackView()
    rows.backgroundColor = .black
    rows.axis = .vertical
    rows.distribution = .equalSpacing
    rows.spacing = 2
    rows.translatesAutoresizingMaskIntoConstraints = false

    for rowIndex in 0..<9 {

      let row = UIStackView()
      row.backgroundColor = .black
      row.axis = .horizontal
      row.distribution = .fillEqually
      row.spacing = 2

      for colIndex in 0..<9 {
        let value = solved[rowIndex][colIndex]
        let label = UILabel()
        label.font = .systemFont(ofSize: 26)
        label.backgroundColor = config[rowIndex][colIndex] == 0 ? .green : .white
        label.text = " \(value) "
        label.textColor = .black
        row.addArrangedSubview(label)
      }
      rows.addArrangedSubview(row)
    }

    view.addSubview(rows)

    view.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:[view]-(<=1)-[rows]",
        options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
        metrics: nil,
        views: ["view":view, "rows":rows]) +
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:[view]-(<=1)-[rows]",
        options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
        metrics: nil,
        views: ["view":view, "rows":rows])
    )

    self.view = view
  }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
