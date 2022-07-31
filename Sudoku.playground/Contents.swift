import UIKit
import PlaygroundSupport

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

  var borderLayer: CALayer?
  var blocks: UIStackView!
  let puzzles = [easy, diabolical, multiple, multiple2, unsolvable]
  let names = ["easy", "diabolical", "multiple", "multiple2", "unsolvable"]
  var index = 0

  override func loadView() {
    let view = UIView()
    view.backgroundColor = .white
    self.view = view
    showPuzzle()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard borderLayer == nil else { return }
    borderLayer = blocks?.addExternalBorder(borderWidth: 4.0, borderColor: .black)
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
    if blocks != nil {
      blocks.removeFromSuperview()
      blocks = nil
      borderLayer = nil
    }

    let puzzle = decode(puzzles[index])
    let solution = Sudoku.solve(board: puzzle)
    blocks = ViewBuilder.buildFrom(config: puzzle,
                                   name: names[index],
                                   solution: solution.board,
                                   solved: solution.solved,
                                   unique: solution.unique)
    blocks.addArrangedSubview(addButtons())
    view.addCenteredSubview(blocks)
    view.setNeedsLayout()
  }

  func addButtons() -> UIStackView {
    let row = UIStackView()
    row.backgroundColor = .white
    row.axis = .horizontal
    row.distribution = .fillEqually
    row.spacing = 8
    row.translatesAutoresizingMaskIntoConstraints = false

    let leftButton = UIButton(type: .system)
    leftButton.setTitle("Prev", for: .normal)
    leftButton.addTarget(self, action: #selector(previousPuzzle), for: .touchDown)
    row.addArrangedSubview(leftButton)

    let rightButton = UIButton(type: .system)
    rightButton.setTitle("Next", for: .normal)
    rightButton.addTarget(self, action: #selector(nextPuzzle), for: .touchDown)
    row.addArrangedSubview(rightButton)

    return row
  }

  @objc func previousPuzzle(sender: UIButton) {
    index = (index == 0 ? puzzles.count : index) - 1
    showPuzzle()
  }

  @objc func nextPuzzle(sender: UIButton) {
    index = (index == puzzles.count - 1 ? -1 : index) + 1
    showPuzzle()
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

  func addExternalBorder(borderWidth: CGFloat, borderColor: UIColor) -> CALayer {
    let externalBorder = CALayer()
    externalBorder.frame = CGRect(x: -borderWidth, y: -borderWidth,
                                  width: frame.size.width + 2 * borderWidth,
                                  height: frame.size.height + 2 * borderWidth)
    externalBorder.borderColor = borderColor.cgColor
    externalBorder.borderWidth = borderWidth

    layer.insertSublayer(externalBorder, at: 0)
    layer.masksToBounds = false

    return externalBorder
  }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
