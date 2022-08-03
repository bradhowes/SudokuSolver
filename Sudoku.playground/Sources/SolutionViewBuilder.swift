import UIKit

public enum SolutionViewBuilder {
  public static func buildFrom(config: [[Int]], solution: [[Int]]?) -> UIStackView {
    makeBlocks(config: config, solution: solution)
  }
}

private func makeBlocks(config: [[Int]], solution: [[Int]]?) -> UIStackView {
  let rows = UIStackView()

  rows.backgroundColor = .black
  rows.axis = .vertical
  rows.distribution = .equalSpacing
  rows.spacing = 4
  rows.translatesAutoresizingMaskIntoConstraints = false

//  rows.addArrangedSubview(makeTitle(name: name))

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

//  rows.addArrangedSubview(makeState(solved: solved, unique: unique))
  return rows
}

private func makeCellBlock(rowIndex: Int, colIndex: Int, config: [[Int]], solution: [[Int]]?) -> UIStackView {
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

private func makeCellRow(rowIndex: Int, colIndex: Int, config: [[Int]], solution: [[Int]]?) -> UIStackView {
  let row = UIStackView()
  row.backgroundColor = .black
  row.axis = .horizontal
  row.distribution = .fillEqually
  row.spacing = 2

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

//private func makeTitle(name: String) -> UILabel {
//  let label = UILabel()
//  label.font = .systemFont(ofSize: 18)
//  label.backgroundColor = .white
//  label.textAlignment = .center
//  label.text = name
//  label.textColor = .black
//  return label
//}
//
//private func makeState(solved: Bool, unique: Bool) -> UIStackView {
//  let row = UIStackView()
//  row.backgroundColor = .white
//  row.axis = .horizontal
//  row.distribution = .fillEqually
//  row.spacing = 8
//
//  let label1 = UILabel()
//  label1.font = .systemFont(ofSize: 18)
//  label1.backgroundColor = .white
//  label1.textAlignment = .center
//  label1.text = "Solved: \(solved)"
//  label1.textColor = solved ? .black : .systemRed
//  row.addArrangedSubview(label1)
//
//  let label2 = UILabel()
//  label2.font = .systemFont(ofSize: 18)
//  label2.backgroundColor = .white
//  label2.textAlignment = .center
//  label2.text = " Unique: \(unique)"
//  label2.textColor = unique ? .black : .systemRed
//  row.addArrangedSubview(label2)
//
//  return row
//}
//
