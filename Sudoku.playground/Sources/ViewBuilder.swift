import UIKit

public enum ViewBuilder {
  public static func buildFrom(config: [[Int]], solution: [[Int]]) -> UIView {
    return makeBlocks(config: config, solution: solution)
  }
}

private func makeBlocks(config: [[Int]], solution: [[Int]]) -> UIView {
  let rows = UIStackView()

  rows.backgroundColor = .black
  rows.axis = .vertical
  rows.distribution = .equalSpacing
  rows.spacing = 4
  rows.translatesAutoresizingMaskIntoConstraints = false

  for rowIndex in stride(from: 0, to: 9, by: 3) {
    let row = UIStackView()
    row.backgroundColor = .black
    row.axis = .horizontal
    row.distribution = .fillEqually
    row.spacing = 4

    for colIndex in stride(from: 0, to: 9, by: 3) {
      let block = makeCellBlock(rowIndex: rowIndex, colIndex: colIndex, config: config, solution: solution)
      row.addArrangedSubview(block)
    }

    rows.addArrangedSubview(row)
  }

  return rows
}

private func makeCellBlock(rowIndex: Int, colIndex: Int, config: [[Int]], solution: [[Int]]) -> UIView {
  let block = UIStackView()
  block.backgroundColor = .black
  block.axis = .vertical
  block.distribution = .equalSpacing
  block.spacing = 2

  for rowOffset in 0..<3 {
    block.addArrangedSubview(makeCellRow(rowIndex: rowIndex + rowOffset, colIndex: colIndex, config: config,
                                         solution: solution))
  }

  return block
}

private func makeCellRow(rowIndex: Int, colIndex: Int, config: [[Int]], solution: [[Int]]) -> UIView {
  let row = UIStackView()
  row.backgroundColor = .black
  row.axis = .horizontal
  row.distribution = .fillEqually
  row.spacing = 2

  let solvedRow = solution[rowIndex]
  let configRow = config[rowIndex]

  for colOffset in 0..<3 {
    let index = colIndex + colOffset
    row.addArrangedSubview(makeCell(value: solvedRow[index], config: configRow[index]))
  }

  return row
}

private func makeCell(value: Int, config: Int) -> UIView {
  let label = UILabel()
  label.font = .systemFont(ofSize: 26)
  label.backgroundColor = config == 0 ? .green : .white
  label.text = " \(value) "
  label.textColor = .black
  return label
}
