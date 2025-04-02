//
//  GoGameView.swift
//  SwiftUIDemo
//
//  Created by 宁侠 on 2024/4/2.
//

import SwiftUI

// 围棋游戏模型
class GoGameModel: ObservableObject {
    // 棋盘尺寸 (传统围棋是19x19，这里为了简化使用9x9)
    static let boardSize = 9
    
    // 棋子状态：无子(0)，黑子(1)，白子(2)
    @Published var board: [[Int]] = Array(repeating: Array(repeating: 0, count: boardSize), count: boardSize)
    
    // 当前轮到谁下：黑(1)或白(2)
    @Published var currentPlayer: Int = 1
    
    // 黑白双方的已吃子数
    @Published var capturedBlack = 0
    @Published var capturedWhite = 0
    
    // 游戏历史，用于悔棋
    private var history: [[[Int]]] = []
    
    // 初始化游戏
    func newGame() {
        board = Array(repeating: Array(repeating: 0, count: GoGameModel.boardSize), count: GoGameModel.boardSize)
        currentPlayer = 1
        capturedBlack = 0
        capturedWhite = 0
        history = []
    }
    
    // 尝试在指定位置放置棋子
    func placeStone(at row: Int, col: Int) -> Bool {
        // 如果位置已有棋子，则不能放置
        guard board[row][col] == 0 else { return false }
        
        // 创建棋盘深拷贝并保存到历史
        let boardCopy = board.map { row in row.map { $0 } }
        history.append(boardCopy)
        
        // 放置棋子
        board[row][col] = currentPlayer
        
        // 检查是否吃子
        let captured = checkCapture(row: row, col: col)
        
        // 如果是黑子下，则记录吃的白子数；如果是白子下，则记录吃的黑子数
        if currentPlayer == 1 {
            capturedWhite += captured
        } else {
            capturedBlack += captured
        }
        
        // 切换玩家
        currentPlayer = currentPlayer == 1 ? 2 : 1
        
        return true
    }
    
    // 检查是否有棋子被吃
    private func checkCapture(row: Int, col: Int) -> Int {
        var capturedCount = 0
        let opponentPlayer = currentPlayer == 1 ? 2 : 1
        
        // 检查四个相邻位置
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        
        for (dx, dy) in directions {
            let newRow = row + dx
            let newCol = col + dy
            
            // 检查位置是否有效
            guard newRow >= 0 && newRow < Self.boardSize && newCol >= 0 && newCol < Self.boardSize else {
                continue
            }
            
            // 如果相邻位置是对手的棋子，检查是否被包围
            if board[newRow][newCol] == opponentPlayer {
                var group = [(newRow, newCol)]
                var checked = Set<String>()
                checked.insert("\(newRow),\(newCol)")
                
                if !hasLiberty(group: &group, checked: &checked) {
                    // 如果没有气，移除这些棋子
                    for (r, c) in group {
                        board[r][c] = 0
                        capturedCount += 1
                    }
                }
            }
        }
        
        return capturedCount
    }
    
    // 检查一组棋子是否有气（liberty）
    private func hasLiberty(group: inout [(Int, Int)], checked: inout Set<String>) -> Bool {
        var hasLiberty = false
        var i = 0
        
        while i < group.count && !hasLiberty {
            let (row, col) = group[i]
            let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
            
            for (dx, dy) in directions {
                let newRow = row + dx
                let newCol = col + dy
                
                // 检查位置是否有效
                guard newRow >= 0 && newRow < Self.boardSize && newCol >= 0 && newCol < Self.boardSize else {
                    continue
                }
                
                let key = "\(newRow),\(newCol)"
                
                if !checked.contains(key) {
                    checked.insert(key)
                    
                    if board[newRow][newCol] == 0 {
                        // 如果有空位，则有气
                        hasLiberty = true
                        break
                    } else if board[newRow][newCol] == board[row][col] {
                        // 如果是同色棋子，加入组
                        group.append((newRow, newCol))
                    }
                }
            }
            
            i += 1
        }
        
        return hasLiberty
    }
    
    // 悔棋
    func undo() -> Bool {
        guard !history.isEmpty else { return false }
        
        board = history.removeLast()
        currentPlayer = currentPlayer == 1 ? 2 : 1
        
        // 悔棋后重新计算吃子数
        recalculateCapturedStones()
        
        return true
    }
    
    // 重新计算吃子数
    private func recalculateCapturedStones() {
        let blackStones = board.flatMap { $0 }.filter { $0 == 1 }.count
        let whiteStones = board.flatMap { $0 }.filter { $0 == 2 }.count
        
        // 计算吃子数量
        // 注意：这种方式假设初始棋盘为空且黑白双方各自下的子数量应该接近相等
        // 如果需要精确计数，应该记录每一步的吃子数
        capturedBlack = (history.count + 1) / 2 - blackStones
        capturedWhite = history.count / 2 - whiteStones
    }
}

// 围棋视图
struct GoGameView: View {
    @StateObject private var game = GoGameModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showHelp = false
    
    // 计算棋盘格子大小
    private let boardSize = GoGameModel.boardSize
    private var cellSize: CGFloat {
        min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.8 / CGFloat(boardSize)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 状态指示
                StatusView(game: game)
                
                // 棋盘
                GoGameBoardView(
                    game: game,
                    boardSize: boardSize,
                    cellSize: cellSize,
                    showAlert: $showAlert,
                    alertMessage: $alertMessage
                )
                
                // 控制按钮
                ControlButtonsView(
                    game: game,
                    showAlert: $showAlert,
                    alertMessage: $alertMessage,
                    showHelp: $showHelp
                )
            }
            .navigationTitle("围棋")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
            .sheet(isPresented: $showHelp) {
                GoGameHelpView()
            }
        }
    }
}

// 状态指示子视图
struct StatusView: View {
    @ObservedObject var game: GoGameModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("黑方吃子: \(game.capturedWhite)")
                    .font(.headline)
                Text("白方吃子: \(game.capturedBlack)")
                    .font(.headline)
            }
            
            Spacer()
            
            Circle()
                .fill(game.currentPlayer == 1 ? Color.black : Color.white)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: game.currentPlayer == 2 ? 1 : 0)
                )
            
            Text(game.currentPlayer == 1 ? "黑方回合" : "白方回合")
                .font(.headline)
        }
        .padding()
    }
}

// 棋盘子视图
struct GoGameBoardView: View {
    @ObservedObject var game: GoGameModel
    let boardSize: Int
    let cellSize: CGFloat
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    var body: some View {
        ZStack {
            // 背景
            Color(UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0))
                .cornerRadius(8)
            
            // 棋盘网格
            BoardGridView(boardSize: boardSize, cellSize: cellSize)
            
            // 天元和星位
            StarPointsView(boardSize: boardSize, cellSize: cellSize)
            
            // 交叉点和棋子
            StonesView(
                game: game,
                boardSize: boardSize,
                cellSize: cellSize,
                showAlert: $showAlert,
                alertMessage: $alertMessage
            )
        }
        .aspectRatio(1.0, contentMode: .fit)
        .padding()
    }
}

// 棋盘网格线视图
struct BoardGridView: View {
    let boardSize: Int
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            // 横线
            ForEach(0..<boardSize, id: \.self) { row in
                Path { path in
                    let y = cellSize * (CGFloat(row) + 0.5)
                    path.move(to: CGPoint(x: cellSize * 0.5, y: y))
                    path.addLine(to: CGPoint(x: cellSize * CGFloat(Double(boardSize) - 0.5), y: y))
                }
                .stroke(Color.black, lineWidth: 1)
            }
            
            // 纵线
            ForEach(0..<boardSize, id: \.self) { col in
                Path { path in
                    let x = cellSize * (CGFloat(col) + 0.5)
                    path.move(to: CGPoint(x: x, y: cellSize * 0.5))
                    path.addLine(to: CGPoint(x: x, y: cellSize * CGFloat(Double(boardSize) - 0.5)))
                }
                .stroke(Color.black, lineWidth: 1)
            }
        }
    }
}

// 天元和星位视图
struct StarPointsView: View {
    let boardSize: Int
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            ForEach([2, 4, 6], id: \.self) { row in
                ForEach([2, 4, 6], id: \.self) { col in
                    if row == 4 && col == 4 {
                        // 天元点
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                            .position(
                                x: cellSize * (CGFloat(col) + 0.5),
                                y: cellSize * (CGFloat(row) + 0.5)
                            )
                    } else {
                        // 星位
                        Circle()
                            .fill(Color.black)
                            .frame(width: 6, height: 6)
                            .position(
                                x: cellSize * (CGFloat(col) + 0.5),
                                y: cellSize * (CGFloat(row) + 0.5)
                            )
                    }
                }
            }
        }
    }
}

// 棋子视图
struct StonesView: View {
    @ObservedObject var game: GoGameModel
    let boardSize: Int
    let cellSize: CGFloat
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<boardSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<boardSize, id: \.self) { col in
                        StonePositionView(
                            game: game,
                            row: row,
                            col: col,
                            cellSize: cellSize,
                            showAlert: $showAlert,
                            alertMessage: $alertMessage
                        )
                    }
                }
            }
        }
    }
}

// 单个棋子位置视图
struct StonePositionView: View {
    @ObservedObject var game: GoGameModel
    let row: Int
    let col: Int
    let cellSize: CGFloat
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
            
            if game.board[row][col] != 0 {
                Circle()
                    .fill(game.board[row][col] == 1 ? Color.black : Color.white)
                    .frame(width: cellSize * 0.9, height: cellSize * 0.9)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 1)
            }
        }
        .contentShape(Rectangle()) // 确保整个区域都能响应点击
        .onTapGesture {
            // 使用主线程确保UI更新
            DispatchQueue.main.async {
                if !game.placeStone(at: row, col: col) {
                    showAlert = true
                    alertMessage = "此位置无法落子"
                }
            }
        }
    }
}

// 控制按钮视图
struct ControlButtonsView: View {
    @ObservedObject var game: GoGameModel
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var showHelp: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: {
                game.newGame()
            }) {
                VStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                    Text("新游戏")
                        .font(.caption)
                }
                .frame(width: 80, height: 60)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            Button(action: {
                if !game.undo() {
                    showAlert = true
                    alertMessage = "没有可以悔棋的步骤"
                }
            }) {
                VStack {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title)
                    Text("悔棋")
                        .font(.caption)
                }
                .frame(width: 80, height: 60)
                .foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(10)
            }
            
            Button(action: {
                showHelp = true
            }) {
                VStack {
                    Image(systemName: "questionmark.circle")
                        .font(.title)
                    Text("帮助")
                        .font(.caption)
                }
                .frame(width: 80, height: 60)
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

// 围棋游戏帮助视图
struct GoGameHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("围棋规则")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                Text("基本规则：")
                    .font(.headline)
                
                Text("• 围棋是一种两人对弈的策略性棋类游戏，黑白双方交替在棋盘交叉点上放置棋子。")
                Text("• 本游戏使用9×9的小棋盘，传统围棋使用19×19的棋盘。")
                Text("• 黑方先行，然后双方轮流下子。")
                
                Text("目标：")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("• 围住对方的棋子，或控制更多的棋盘领域。")
                Text("• 被完全包围的棋子会被提走（吃子）。")
                
                Text("气：")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("• 每个棋子的相邻空点称为'气'。")
                Text("• 相连的同色棋子形成一个组，共享气。")
                Text("• 当一组棋子没有气时，这组棋子被提走。")
                
                Text("操作说明：")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("• 点击棋盘上的交叉点放置棋子。")
                Text("• 使用'新游戏'按钮开始新的对局。")
                Text("• 使用'悔棋'按钮撤销上一步。")
                
                Spacer()
            }
            .padding()
        }
    }
}

struct GoGameView_Previews: PreviewProvider {
    static var previews: some View {
        GoGameView()
    }
} 
