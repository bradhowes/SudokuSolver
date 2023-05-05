import UIKit

public enum SolutionViewBuilder {
  public static func buildFrom(config: [[Int]], solution: [[Int]]?) -> UIStackView {
    makeBlocks(config: config, solution: solution)
  }
}

private func makeBlocks(config: [[Int]], solution: [[Int]]?) -> UIStackView {
  let rows = UIStackView()
  configureStackView(rows, axis: .vertical, distribution: .equalSpacing, spacing: 4)
  rows.translatesAutoresizingMaskIntoConstraints = false
  for rowIndex in stride(from: 0, to: 9, by: 3) {
    let row = UIStackView()
    configureStackView(row, axis: .horizontal, distribution: .fillEqually, spacing: 4)
    for colIndex in stride(from: 0, to: 9, by: 3) {
      row.addArrangedSubview(makeCellBlock(rowIndex: rowIndex, colIndex: colIndex, config: config, solution: solution))
    }
    rows.addArrangedSubview(row)
  }
  return rows
}

private func makeCellBlock(rowIndex: Int, colIndex: Int, config: [[Int]], solution: [[Int]]?) -> UIStackView {
  let block = UIStackView()
  configureStackView(block, axis: .vertical, distribution: .equalSpacing, spacing: 2)
  for rowOffset in 0..<3 {
    block.addArrangedSubview(makeCellRow(rowIndex: rowIndex + rowOffset, colIndex: colIndex, config: config,
                                         solution: solution))
  }
  return block
}

private func makeCellRow(rowIndex: Int, colIndex: Int, config: [[Int]], solution: [[Int]]?) -> UIStackView {
  let row = UIStackView()
  configureStackView(row, axis: .horizontal, distribution: .fillEqually, spacing: 2)
  let configRow = config[rowIndex]
  let solvedRow = solution?[rowIndex] ?? configRow
  for colOffset in 0..<3 {
    let index = colIndex + colOffset
    row.addArrangedSubview(makeCell(value: solvedRow[index], config: configRow[index]))
  }
  return row
}

private func makeCell(value: Int, config: Int) -> UILabel {
  let label = UILabel()
  label.font = .systemFont(ofSize: 26)
  label.backgroundColor = config == 0 ? .green : .white
  label.text = " \(value) "
  label.textColor = .black
  return label
}

private func configureStackView(_ stackView: UIStackView, axis: NSLayoutConstraint.Axis,
                                distribution: UIStackView.Distribution, spacing: CGFloat) {
  stackView.backgroundColor = .black
  stackView.axis = axis
  stackView.distribution = distribution
  stackView.spacing = spacing
}
