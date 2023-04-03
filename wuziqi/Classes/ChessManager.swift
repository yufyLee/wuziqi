//
//  ChessManager.swift
//  gomoku
//
//  Created by LYF on 2023/2/28.
//

import Foundation

/// 管理数据
public class ChessManager {
    
    // 单例
    public static let shared = ChessManager()
    private init() {}

    /// 棋盘等级
    public enum Level: Int {
        // 棋盘每行、列的 格子数
        case basic = 11
        case high = 15
    }
    public enum Role: String {
        case white = "白方"
        case black = "黑方"
        // 默认我是黑色先手
        var isBlack: Bool {
            switch self {
            case .black:
                return true
            default:
                return false
            }
        }
    }
    /// 默认棋盘等级普通
    public var level: Level = .basic
    /// 默认先手
    public var currentRole: Role = .black
    /// 缓存棋子
    var chessmanArray = [Chessman]()
    /// 缓存一条线上相邻的同色棋子
    var sameColorChess = [Chessman]()
}

//MARK: - 数据校验
extension ChessManager {
    
    /// 检查落子位置是否合理
    /// - Parameters:
    ///   - col: 列坐标
    ///   - row: 行坐标
    /// - Returns: 位置是否合适
    func isLocationOK(col: Int, row: Int) -> Bool {
        if let _ = chessmanArray.first(where: {$0.col == col && $0.row == row}) {
            return false
        }
        return true
    }
    
    /// 检查游戏是否结束(包括胜利和平局)
    
    /// 是否是平局
    /// - Returns: result
    func checkDrawLevel() -> Bool {
        let total = level.rawValue * level.rawValue
        return chessmanArray.count == total
    }
    
    /// 从当前落子点的上下、左右、左斜、右斜 四个方向判断是否有 5 个棋子相连
    /// - Parameters:
    ///   - col: 当前落子的列坐标
    ///   - row: 当前落子的行坐标
    /// - Returns: 结果 默认 false
    func checkAnyoneWin(col: Int, row: Int) -> Bool {
        //MARK: - 上下方向，坐标 row 变化
        // 上 row --, 临界值 row = 0
        for i in 1...4 {
            let preRow = row - i
            guard preRow >= 0 else { break }
            // 按照row逐行向上检查，如果没有同色棋子则直接结束查找
            if let preChessman = chessmanArray.first(where: {$0.col == col && $0.row == preRow && $0.isBlack == currentRole.isBlack}) {
                sameColorChess.append(preChessman)
            }
            else {
                //只要不连续就跳出循环
                break
            }
        }
        // 下 row ++  临界值最大格子数
        for i in 1...4 {
            let afterRow = row + i
            guard afterRow <= level.rawValue else { break }
            // 按照row逐行向下检查，如果没有同色棋子则直接结束查找
            if let afterChessman = chessmanArray.first(where: {$0.col == col && $0.row == afterRow && $0.isBlack == currentRole.isBlack}){
                sameColorChess.append(afterChessman)
            }
            else {
                //只要不连续就跳出循环
                break
            }
        }
        if sameColorChess.count >= 4 {
            return true
        }
        // 换方向检查结果，清空缓存
        sameColorChess.removeAll()
        //MARK: - 左右方向，坐标 col 变化
        // 左 col-- 临界值 col = 0
        for i in 1...4 {
            let preCol = col - i
            guard preCol >= 0 else { break }
            if let preChessman = chessmanArray.first(where: {$0.col == preCol && $0.row == row && $0.isBlack == currentRole.isBlack}) {
                sameColorChess.append(preChessman)
            }
            else {
                break
            }
        }
        // 右 col++ 临界值 col=最大格子数
        for i in 1...4 {
            let afterCol = col + i
            guard afterCol <= level.rawValue else { break }
            if let afterChessman = chessmanArray.first(where: {$0.col == afterCol && $0.row == row && $0.isBlack == currentRole.isBlack}) {
                sameColorChess.append(afterChessman)
            }
            else {
                break
            }
        }
        if sameColorChess.count >= 4 {
            return true
        }
        // 换方向检查结果，清空缓存
        sameColorChess.removeAll()
        //MARK: - 左斜方向，坐标 col，row 都变化
        // 左上 col--,row--, 临界值 col = 0, row = 0
        for i in 1...4 {
            let preRow = row - i
            let preCol = col - i
            guard preCol >= 0 && preRow >= 0 else { break }
            if let preChessman = chessmanArray.first(where: { $0.col == preCol && $0.row == preRow && $0.isBlack == currentRole.isBlack }) {
                sameColorChess.append(preChessman)
            }
            else {
                break
            }
        }
        // 右下 col++,row++, 临界值 col = 最大格子数, row = 最大格子数
        for i in 1...4 {
            let afterCol = col + i
            let afterRow = row + i
            guard afterCol <= level.rawValue && afterRow <= level.rawValue else { break }
            if let afterChessman = chessmanArray.first(where: { $0.col == afterCol && $0.row == afterRow && $0.isBlack == currentRole.isBlack }){
                sameColorChess.append(afterChessman)
            }
            else {
                break
            }
        }
        if sameColorChess.count >= 4 {
            return true
        }
        // 换方向检查结果，清空缓存
        sameColorChess.removeAll()
        //MARK: - 右斜方向，坐标 col，row 都变化
        // 右上 col++,row--, 临界值 col = 最大格子数，row = 0
        for i in 1...4 {
            let preRow = row - i
            let afterCol = col + i
            guard preRow >= 0 && afterCol < level.rawValue else { break }
            if let tempChessman = chessmanArray.first(where: { $0.row == preRow && $0.col == afterCol && $0.isBlack == currentRole.isBlack }) {
                sameColorChess.append(tempChessman)
            }
            else {
                break
            }
        }
        // 左下 col--,row++, 临界值 row = 最大格子数，col = 0
        for i in 1...4 {
            let preCol = col - i
            let afterRow = row + i
            guard preCol >= 0 && afterRow <= level.rawValue else { break }
            if let tempChessman = chessmanArray.first(where: { $0.row == afterRow && $0.col == preCol && $0.isBlack == currentRole.isBlack }) {
                sameColorChess.append(tempChessman)
            }
            else {
                break
            }
        }
        if sameColorChess.count >= 4 {
            return true
        }
        // 清空缓存
        sameColorChess.removeAll()
        return false
    }
}
