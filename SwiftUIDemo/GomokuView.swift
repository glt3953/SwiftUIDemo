//
//  GomokuView.swift
//  SwiftUIDemo
//
//  Created by 宁侠 on 2025/4/1.
//

import SwiftUI

// 棋子类型
enum ChessPiece: Int {
    case none = 0
    case black = 1
    case white = 2
}

// 游戏状态
enum GomokuGameState {
    case playing
    case blackWin
    case whiteWin
    case draw
}

// 五子棋游戏视图模型
class GomokuViewModel: ObservableObject {
    // 棋盘大小
    let boardSize = 15
    
    // 棋盘状态
    @Published var board: [[ChessPiece]]
    
    // 当前玩家
    @Published var currentPlayer: ChessPiece = .black
    
    // 游戏状态
    @Published var gameState: GomokuGameState = .playing
    
    init() {
        // 初始化空棋盘
        board = Array(repeating: Array(repeating: .none, count: 15), count: 15)
    }
    
    // 放置棋子
    func placePiece(at row: Int, col: Int) {
        // 如果游戏已结束或位置已有棋子，则返回
        if gameState != .playing || board[row][col] != .none {
            return
        }
        
        // 放置棋子
        board[row][col] = currentPlayer
        
        // 检查是否获胜
        if checkWin(row: row, col: col) {
            gameState = currentPlayer == .black ? .blackWin : .whiteWin
            return
        }
        
        // 检查是否平局（棋盘已满）
        if isBoardFull() {
            gameState = .draw
            return
        }
        
        // 切换玩家
        currentPlayer = currentPlayer == .black ? .white : .black
    }
    
    // 检查是否获胜
    func checkWin(row: Int, col: Int) -> Bool {
        let player = board[row][col]
        
        // 检查水平方向
        if countConsecutive(row: row, col: col, dRow: 0, dCol: 1) >= 5 {
            return true
        }
        
        // 检查垂直方向
        if countConsecutive(row: row, col: col, dRow: 1, dCol: 0) >= 5 {
            return true
        }
        
        // 检查左上到右下对角线
        if countConsecutive(row: row, col: col, dRow: 1, dCol: 1) >= 5 {
            return true
        }
        
        // 检查右上到左下对角线
        if countConsecutive(row: row, col: col, dRow: 1, dCol: -1) >= 5 {
            return true
        }
        
        return false
    }
    
    // 计算连续棋子数量
    func countConsecutive(row: Int, col: Int, dRow: Int, dCol: Int) -> Int {
        let player = board[row][col]
        var count = 1
        
        // 向一个方向计数
        var r = row + dRow
        var c = col + dCol
        while r >= 0 && r < boardSize && c >= 0 && c < boardSize && board[r][c] == player {
            count += 1
            r += dRow
            c += dCol
        }
        
        // 向另一个方向计数
        r = row - dRow
        c = col - dCol
        while r >= 0 && r < boardSize && c >= 0 && c < boardSize && board[r][c] == player {
            count += 1
            r -= dRow
            c -= dCol
        }
        
        return count
    }
    
    // 检查棋盘是否已满
    func isBoardFull() -> Bool {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                if board[row][col] == .none {
                    return false
                }
            }
        }
        return true
    }
    
    // 重置游戏
    func resetGame() {
        board = Array(repeating: Array(repeating: .none, count: 15), count: 15)
        currentPlayer = .black
        gameState = .playing
    }
}

// 五子棋游戏视图
struct GomokuView: View {
    @StateObject private var viewModel = GomokuViewModel()
    @State private var boardSize: CGFloat = 0
    
    var body: some View {
        VStack {
            // 状态指示器
            statusView
                .padding()
            
            // 棋盘视图
            GeometryReader { geometry in
                let minDimension = min(geometry.size.width, geometry.size.height)
                let cellSize = minDimension / CGFloat(viewModel.boardSize)
                
                ZStack {
                    // 棋盘背景
                    Rectangle()
                        .fill(Color(UIColor.systemBrown).opacity(0.7))
                        .border(Color.black, width: 1)
                    
                    // 棋盘网格线
                    boardGridView(cellSize: cellSize)
                    
                    // 棋子
                    chessPiecesView(cellSize: cellSize)
                }
                .frame(width: minDimension, height: minDimension)
                .onAppear {
                    boardSize = minDimension
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            handleTap(at: value.location, cellSize: cellSize)
                        }
                )
            }
            .padding()
            
            // 重置按钮
            Button(action: {
                viewModel.resetGame()
            }) {
                Text("重新开始")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("五子棋")
    }
    
    // 状态视图
    var statusView: some View {
        HStack {
            switch viewModel.gameState {
            case .playing:
                Text("当前玩家: \(viewModel.currentPlayer == .black ? "黑棋" : "白棋")")
                    .font(.title3)
                    .foregroundColor(viewModel.currentPlayer == .black ? .black : .white)
                    .padding(5)
                    .background(viewModel.currentPlayer == .black ? Color.white : Color.black)
                    .cornerRadius(5)
            case .blackWin:
                Text("黑棋胜利！")
                    .font(.title3)
                    .foregroundColor(.black)
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(5)
            case .whiteWin:
                Text("白棋胜利！")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.black)
                    .cornerRadius(5)
            case .draw:
                Text("平局！")
                    .font(.title3)
                    .padding(5)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(5)
            }
        }
    }
    
    // 棋盘网格线视图
    func boardGridView(cellSize: CGFloat) -> some View {
        ZStack {
            // 水平线
            ForEach(0..<viewModel.boardSize, id: \.self) { row in
                Path { path in
                    path.move(to: CGPoint(x: cellSize / 2, y: cellSize / 2 + CGFloat(row) * cellSize))
                    path.addLine(to: CGPoint(x: boardSize - cellSize / 2, y: cellSize / 2 + CGFloat(row) * cellSize))
                }
                .stroke(Color.black, lineWidth: 1)
            }
            
            // 垂直线
            ForEach(0..<viewModel.boardSize, id: \.self) { col in
                Path { path in
                    path.move(to: CGPoint(x: cellSize / 2 + CGFloat(col) * cellSize, y: cellSize / 2))
                    path.addLine(to: CGPoint(x: cellSize / 2 + CGFloat(col) * cellSize, y: boardSize - cellSize / 2))
                }
                .stroke(Color.black, lineWidth: 1)
            }
            
            // 标记点
            ForEach([3, 7, 11], id: \.self) { row in
                ForEach([3, 7, 11], id: \.self) { col in
                    Circle()
                        .fill(Color.black)
                        .frame(width: 6, height: 6)
                        .position(x: cellSize / 2 + CGFloat(col) * cellSize, 
                                  y: cellSize / 2 + CGFloat(row) * cellSize)
                }
            }
        }
    }
    
    // 棋子视图
    func chessPiecesView(cellSize: CGFloat) -> some View {
        ZStack {
            ForEach(0..<viewModel.boardSize, id: \.self) { row in
                ForEach(0..<viewModel.boardSize, id: \.self) { col in
                    if viewModel.board[row][col] != .none {
                        Circle()
                            .fill(viewModel.board[row][col] == .black ? Color.black : Color.white)
                            .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                            .shadow(color: .gray, radius: 2, x: 1, y: 1)
                            .position(x: cellSize / 2 + CGFloat(col) * cellSize, 
                                      y: cellSize / 2 + CGFloat(row) * cellSize)
                    }
                }
            }
        }
    }
    
    // 处理点击事件
    func handleTap(at location: CGPoint, cellSize: CGFloat) {
        // 计算点击的行列
        let col = Int(location.x / cellSize)
        let row = Int(location.y / cellSize)
        
        // 确保点击在棋盘范围内
        if row >= 0 && row < viewModel.boardSize && col >= 0 && col < viewModel.boardSize {
            viewModel.placePiece(at: row, col: col)
        }
    }
}

struct GomokuView_Previews: PreviewProvider {
    static var previews: some View {
        GomokuView()
    }
} 