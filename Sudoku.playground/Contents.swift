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
let solution = Sudoku.solve(board: config)

class MyViewController : UIViewController {

  var borderLayer: CALayer?
  var blocks: UIView!

  override func loadView() {
    let view = UIView()
    view.backgroundColor = .white
    blocks = ViewBuilder.buildFrom(config: config, solution: solution)
    view.addCenteredSubview(blocks)
    self.view = view
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard borderLayer == nil else { return }
    borderLayer = blocks?.addExternalBorder(borderWidth: 4.0, borderColor: .black)
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
