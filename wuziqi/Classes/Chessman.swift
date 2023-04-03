//
//  Chessman.swift
//  gomoku
//
//  Created by LYF on 2023/2/28.
//

import Foundation
import QuartzCore
import UIKit

class Chessman: UIView {
    // 棋子位置
    let col, row: Int
    // 棋子颜色
    let isBlack: Bool
    
    /// 棋子占格子大小的比例
    fileprivate let chessRadio: CGFloat = 0.75
    
    required init(col: Int, row: Int, isBlack: Bool, gridWidth: CGFloat) {
        self.col = col
        self.row = row
        self.isBlack = isBlack
        super.init(frame: CGRect(x: 0, y: 0, width: gridWidth * chessRadio, height: gridWidth * chessRadio))
        self.backgroundColor = isBlack ? .black : .white
        self.layer.cornerRadius = gridWidth * chessRadio * 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
