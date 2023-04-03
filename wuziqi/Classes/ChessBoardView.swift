//
//  ChessBoardView.swift
//  gomoku
//
//  Created by LYF on 2023/2/28.
//

import Foundation
import UIKit

/// 棋盘周围间距（px）
fileprivate let boardSpace: CGFloat = 20.0

/// 屏幕宽
fileprivate let screenW = UIScreen.main.bounds.width
/// 适配比例
fileprivate let radioW = UIScreen.main.bounds.width / 375.0

public protocol ChessBoardViewDelegate: AnyObject {
    
    /// 游戏结束，平局
    func gameIsDrawLevel()
    
    /// 游戏结束，某人获胜
    func gameIsOver()
}

public class ChessBoardView: UIView {
    
    // 初始化棋盘，保证棋盘是正方形
    public override init(frame: CGRect) {
        let wh = min(frame.width, frame.height)
        super.init(frame: CGRect(x: frame.minX, y: frame.minY, width: wh, height: wh))
        setUp()
    }
    
    required init?(coder: NSCoder) {
        //xib 未实现
        fatalError("init(coder:) has not been implemented")
    }
    
    public weak var delegate: ChessBoardViewDelegate?
    
    private var gridWidth: CGFloat = 0.0
    
    private lazy var boardImageView: UIImageView = {
        let v = UIImageView()
        return v
    }()
}

//MARK: - 绘制棋盘
extension ChessBoardView {
    // 初始化工作
    func setUp() {
        // 棋盘背景颜色
        self.backgroundColor = UIColor(red: 200/255.0, green: 160/255.0, blue: 130/255.0, alpha: 1.0)
        self.addSubview(self.boardImageView)
        // 绘制棋盘
        drawBoardInSize(self.bounds.size)
        self.boardImageView.sizeToFit()
        // 添加落子手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(moveInChess(_:)))
        self.addGestureRecognizer(tap)
    }
    
    // 绘制工作
    func drawBoardInSize(_ size: CGSize) {
        let count = ChessManager.shared.level.rawValue
        // 格子宽高
        self.gridWidth = (size.width - boardSpace * 2) / CGFloat(count)
        // 开启图像绘制上下文
        UIGraphicsBeginImageContext(size)
        // 获取上下文
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx.setLineWidth(0.8)
        // 画竖线
        for i in 0...count {
            ctx.move(to: CGPoint(x: boardSpace + CGFloat(i) * self.gridWidth, y: boardSpace))
            ctx.addLine(to: CGPoint(x: boardSpace + CGFloat(i) * self.gridWidth, y: boardSpace + CGFloat(count) * self.gridWidth))
        }
        // 画横线
        for j in 0...count {
            ctx.move(to: CGPoint(x: boardSpace, y: boardSpace + CGFloat(j) * self.gridWidth))
            ctx.addLine(to: CGPoint(x: boardSpace + CGFloat(count) * self.gridWidth, y: boardSpace + CGFloat(j) * self.gridWidth))
        }
        
        ctx.strokePath()
        
        //生成图片添加到父视图上
        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.boardImageView.image = image
        UIGraphicsEndImageContext()
    }
}

//MARK: - 点击事件
extension ChessBoardView {
    // 落子检查
    @objc func moveInChess(_ tap: UITapGestureRecognizer) {
        //MARK: - 计算落子位置对应棋盘位置
        let point = tap.location(in: tap.view)
        // 四舍五入取整
        let col = ((point.x - boardSpace) / self.gridWidth).rounded()
        let row = ((point.y - boardSpace) / self.gridWidth).rounded()
        
        //MARK: - 检查落子是否成功（是否重叠）
        guard ChessManager.shared.isLocationOK(col: Int(col), row: Int(row)) else {
            debugPrint("位置重叠，落子失败~")
            return
        }
        //MARK: - 创建棋子
        let chessman = Chessman(col: Int(col), row: Int(row), isBlack: ChessManager.shared.currentRole.isBlack, gridWidth: gridWidth)
        self.addSubview(chessman)
        chessman.center = CGPoint(x: boardSpace + col * gridWidth, y: boardSpace + row * gridWidth)
        ChessManager.shared.chessmanArray.append(chessman)
        //MARK: - 检查是否获胜
        if ChessManager.shared.checkAnyoneWin(col: Int(col), row: Int(row)) {
            //MARK: - 如果游戏结束，提示
            ChessManager.shared.sameColorChess.append(chessman)
            animationChess()
            delegate?.gameIsOver()
            debugPrint("游戏结束,\(ChessManager.shared.currentRole.rawValue)获胜")
        }
        else if ChessManager.shared.checkDrawLevel() {
            debugPrint("游戏结束,平局")
            delegate?.gameIsDrawLevel()
        }
        else {
            //更换角色,继续
            ChessManager.shared.currentRole = ChessManager.shared.currentRole == .black ? .white : .black
        }
    }
}

//MARK: - Private
extension ChessBoardView {
    // 添加动画
    func animationChess() {
        for chess in ChessManager.shared.sameColorChess {
            let animation = CAKeyframeAnimation()
            animation.values = [1, 0, 1]
            animation.repeatCount = Float.infinity
            animation.keyPath = "opacity"
            animation.duration = 1
            chess.layer.add(animation, forKey: "opacity")
        }
    }
}

//MARK: - public
extension ChessBoardView {
    
    /// 重置棋盘
    public func reset() {
        for item in self.subviews {
            if item.isKind(of: Chessman.self) {
                item.layer.removeAllAnimations()
                item.removeFromSuperview()
            }
        }
        
        ChessManager.shared.currentRole = .black
        ChessManager.shared.chessmanArray.removeAll()
        ChessManager.shared.sameColorChess.removeAll()
    }
}

