//
//  ViewController.swift
//  Demo
//
//  Created by WanYi Yu on 2025/7/17.
//

import UIKit

class ViewController: UIViewController {

    private var board: [[String]] = [["", "", ""], ["", "", ""], ["", "", ""]]
    private var playerSymbol: String = "X"
    private var systemSymbol: String = "O"
    private var buttons: [[UIButton]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // showSymbolSelectionAlert() // 移除這一行
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSymbolSelectionAlert()
    }

    private func showSymbolSelectionAlert() {
        let alert = UIAlertController(title: "Choose Your Character", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cat", style: .default, handler: { _ in
            self.playerSymbol = "cat"
            self.systemSymbol = "dog"
            self.setupBoard()
        }))
        alert.addAction(UIAlertAction(title: "Dog", style: .default, handler: { _ in
            self.playerSymbol = "dog"
            self.systemSymbol = "cat"
            self.setupBoard()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func setupBoard() {
        buttons = [] // 清空按鈕陣列，避免重複
        let buttonSize: CGFloat = view.frame.size.width / 3
        let boardHeight = buttonSize * 3
        let boardY = (view.frame.size.height - boardHeight) / 2

        for row in 0..<3 {
            var buttonRow: [UIButton] = []
            for col in 0..<3 {
                let button = UIButton(frame: CGRect(x: CGFloat(col) * buttonSize, y: boardY + CGFloat(row) * buttonSize, width: buttonSize, height: buttonSize))
                button.backgroundColor = .clear

                // 設定內部框線，最外圈無框線
                if row > 0 {
                    button.layer.addSublayer(createBorderLayer(frame: button.bounds, edge: .top))
                }
                if col > 0 {
                    button.layer.addSublayer(createBorderLayer(frame: button.bounds, edge: .left))
                }

                button.setTitle("", for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
                button.setTitleColor(.black, for: .normal)
                button.tag = row * 3 + col
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                view.addSubview(button)
                buttonRow.append(button)
            }
            buttons.append(buttonRow)
        }

        // 設定背景圖片
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "grass_background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    private func createBorderLayer(frame: CGRect, edge: UIRectEdge) -> CALayer {
        let border = CALayer()
        border.backgroundColor = UIColor.black.cgColor
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: 2)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: 2, height: frame.height)
        default:
            break
        }
        return border
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        let row = sender.tag / 3
        let col = sender.tag % 3

        if board[row][col] == "" {
            board[row][col] = playerSymbol
            sender.setImage(UIImage(named: playerSymbol), for: .normal)
            if checkWinner() {
                showAlert(title: "Player Wins!")
            } else if checkDraw() {
                showAlert(title: "It's a Draw!")
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.systemMove()
                }
            }
        }
    }

    private func systemMove() {
        var emptySpaces: [(Int, Int)] = []
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == "" {
                    emptySpaces.append((row, col))
                }
            }
        }

        if let randomSpace = emptySpaces.randomElement() {
            let (row, col) = randomSpace
            board[row][col] = systemSymbol
            buttons[row][col].setImage(UIImage(named: systemSymbol), for: .normal)
            if checkWinner() {
                showAlert(title: "System Wins!")
            } else if checkDraw() {
                showAlert(title: "It's a Draw!")
            }
        }
    }

    private func checkWinner() -> Bool {
        for row in board {
            if row[0] != "" && row[0] == row[1] && row[1] == row[2] {
                return true
            }
        }

        for col in 0..<3 {
            if board[0][col] != "" && board[0][col] == board[1][col] && board[1][col] == board[2][col] {
                return true
            }
        }

        if board[0][0] != "" && board[0][0] == board[1][1] && board[1][1] == board[2][2] {
            return true
        }

        if board[0][2] != "" && board[0][2] == board[1][1] && board[1][1] == board[2][0] {
            return true
        }

        return false
    }

    private func checkDraw() -> Bool {
        for row in board {
            if row.contains("") {
                return false
            }
        }
        return true
    }

    private func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.view.tintColor = UIColor.systemBlue
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.resetGame()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func resetGame() {
        board = [["", "", ""], ["", "", ""], ["", "", ""]]
        buttons.forEach { row in
            row.forEach { button in
                button.setTitle("", for: .normal)
                button.setImage(nil, for: .normal) // 清除圖示
            }
        }
        setupBoard() // 重新建立棋盤
        showSymbolSelectionAlert() // 顯示選擇符號的提示
    }
}

