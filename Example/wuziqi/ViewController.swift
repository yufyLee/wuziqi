//
//  ViewController.swift
//  wuziqi
//
//  Created by yufylee on 04/03/2023.
//  Copyright (c) 2023 yufylee. All rights reserved.
//

import UIKit
import wuziqi

class ViewController: UIViewController {

    private lazy var chessBoard: ChessBoardView = {
        let v = ChessBoardView(frame: CGRect(x: 20, y: 30, width: view.bounds.width * 0.95, height: view.bounds.height))
        v.delegate = self
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .lightGray
        view.addSubview(self.chessBoard)
        self.chessBoard.center = view.center
    }

    // 提示
    func alert(message: String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let leftA = UIAlertAction(title: "再来一局", style: .default) { _ in
            self.chessBoard.reset()
        }
        alert.addAction(leftA)
        present(alert, animated: true, completion: nil)
    }

}

extension ViewController: ChessBoardViewDelegate {
    // 平局
    func gameIsDrawLevel() {
         alert(message: "游戏结束--平局")
    }
    // 一方获胜
    func gameIsOver() {
        alert(message: "游戏结束--\(ChessManager.shared.currentRole.rawValue)获胜！")
    }
}

