//
//  SudokuView.swift
//  SwiftUIDemo
//
//  Created by 宁侠 on 2024/4/1.
//

import SwiftUI

// 数独视图
struct SudokuView: View {
    // 数独游戏模型
    @StateObject private var game = SudokuGame()
    @State private var selectedCell: (row: Int, col: Int)? = nil
    @State private var showError = false
    @State private var errorMessage = ""
    
    // 格子大小
    private let cellSize: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 9 - 4
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 数独网格
                        VStack(spacing: 1) {
                            ForEach(0..<9) { row in
                                HStack(spacing: 1) {
                                    ForEach(0..<9) { col in
                                        let isFixed = game.initialBoard[row][col] > 0
                                        
                                        CellView(
                                            value: game.board[row][col],
                                            isSelected: selectedCell?.row == row && selectedCell?.col == col,
                                            isFixed: isFixed,
                                            hasSameValue: selectedCell != nil && game.board[row][col] > 0 &&
                                                game.board[row][col] == game.board[selectedCell!.row][selectedCell!.col] &&
                                                !(row == selectedCell!.row && col == selectedCell!.col),
                                            isSameRow: selectedCell?.row == row,
                                            isSameCol: selectedCell?.col == col,
                                            isSameBlock: isSameBlock(row: row, col: col, selectedRow: selectedCell?.row, selectedCol: selectedCell?.col)
                                        )
                                        .frame(width: cellSize, height: cellSize)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            if !isFixed {
                                                selectedCell = (row, col)
                                            }
                                        }
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.black, lineWidth: (col % 3 == 0 && col > 0) || (row % 3 == 0 && row > 0) ? 2 : 0.5)
                                        )
                                    }
                                }
                            }
                        }
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                        
                        // 数字键盘
                        VStack(spacing: 10) {
                            ForEach(0..<3) { row in
                                HStack(spacing: 10) {
                                    ForEach(1..<4) { col in
                                        let number = row * 3 + col
                                        Button(action: {
                                            insertNumber(number)
                                        }) {
                                            Text("\(number)")
                                                .font(.title2)
                                                .fontWeight(.medium)
                                                .frame(width: 50, height: 50)
                                                .background(Color.blue.opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            
                            HStack(spacing: 10) {
                                Button(action: {
                                    if let selectedCell = selectedCell {
                                        game.board[selectedCell.row][selectedCell.col] = 0
                                    }
                                }) {
                                    Text("清除")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .frame(width: 110, height: 50)
                                        .background(Color.red.opacity(0.2))
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    game.newGame()
                                    selectedCell = nil
                                }) {
                                    Text("新游戏")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .frame(width: 110, height: 50)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 功能按钮
                        HStack(spacing: 20) {
                            // 提示按钮
                            Button(action: {
                                if let hint = game.getHint() {
                                    game.board[hint.row][hint.col] = hint.value
                                    selectedCell = (hint.row, hint.col)
                                } else {
                                    showError = true
                                    errorMessage = "没有可用的提示或游戏已完成"
                                }
                            }) {
                                VStack {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.title2)
                                    Text("提示")
                                        .font(.footnote)
                                }
                                .frame(width: 70, height: 70)
                                .foregroundColor(.orange)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            // 验证按钮
                            Button(action: {
                                if game.isBoardValid() {
                                    if game.isBoardComplete() {
                                        showError = true
                                        errorMessage = "恭喜！您已完成数独游戏！"
                                    } else {
                                        showError = true
                                        errorMessage = "数独有效，但尚未完成"
                                    }
                                } else {
                                    showError = true
                                    errorMessage = "数独无效，请检查您的输入"
                                }
                            }) {
                                VStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                    Text("验证")
                                        .font(.footnote)
                                }
                                .frame(width: 70, height: 70)
                                .foregroundColor(.purple)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.vertical)
                        
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("数独游戏")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("提示"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
    }
    
    // 插入数字
    private func insertNumber(_ number: Int) {
        guard let selectedCell = selectedCell else { return }
        
        // 如果是固定数字则不能修改
        if game.initialBoard[selectedCell.row][selectedCell.col] > 0 {
            showError = true
            errorMessage = "无法修改初始数字"
            return
        }
        
        game.board[selectedCell.row][selectedCell.col] = number
    }
    
    // 判断单元格是否在同一个3x3块中
    private func isSameBlock(row: Int, col: Int, selectedRow: Int?, selectedCol: Int?) -> Bool {
        guard let sRow = selectedRow, let sCol = selectedCol else { return false }
        
        let blockRow = row / 3
        let blockCol = col / 3
        let selectedBlockRow = sRow / 3
        let selectedBlockCol = sCol / 3
        
        return blockRow == selectedBlockRow && blockCol == selectedBlockCol
    }
}

// 单元格视图
struct CellView: View {
    var value: Int
    var isSelected: Bool
    var isFixed: Bool
    var hasSameValue: Bool
    var isSameRow: Bool
    var isSameCol: Bool
    var isSameBlock: Bool
    
    var body: some View {
        ZStack {
            // 背景
            Rectangle()
                .fill(backgroundColor)
            
            // 数字
            if value > 0 {
                Text("\(value)")
                    .font(.title)
                    .foregroundColor(isFixed ? .black : .blue)
                    .fontWeight(isFixed ? .bold : .regular)
            }
        }
    }
    
    // 单元格背景色
    private var backgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.3)
        } else if hasSameValue {
            return Color.green.opacity(0.2)
        } else if isSameRow || isSameCol || isSameBlock {
            return Color.gray.opacity(0.1)
        } else {
            return Color.white
        }
    }
}

// 数独游戏模型
class SudokuGame: ObservableObject {
    // 当前游戏板
    @Published var board: [[Int]]
    // 初始游戏板（用于确定哪些数字是固定的）
    @Published var initialBoard: [[Int]]
    
    // 难度级别
    enum Difficulty {
        case easy, medium, hard
    }
    
    init() {
        self.board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        self.initialBoard = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        newGame(difficulty: .easy)
    }
    
    // 开始新游戏
    func newGame(difficulty: Difficulty = .easy) {
        // 重置游戏版
        board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        
        // 生成完整的数独解决方案
        generateSolution()
        
        // 根据难度级别移除数字
        var cellsToRemove: Int
        switch difficulty {
        case .easy:
            cellsToRemove = 40 // 保留41个数字
        case .medium:
            cellsToRemove = 50 // 保留31个数字
        case .hard:
            cellsToRemove = 60 // 保留21个数字
        }
        
        // 复制当前解决方案到初始版
        initialBoard = board
        
        // 随机移除数字
        var removed = 0
        while removed < cellsToRemove {
            let row = Int.random(in: 0..<9)
            let col = Int.random(in: 0..<9)
            
            if initialBoard[row][col] != 0 {
                initialBoard[row][col] = 0
                board[row][col] = 0
                removed += 1
            }
        }
    }
    
    // 生成有效的数独解决方案
    private func generateSolution() {
        // 简单起见，使用预设的数独解决方案
        let solution = [
            [5, 3, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 2, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 9, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 7, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 7, 4, 1, 9, 6, 3, 5],
            [3, 4, 5, 2, 8, 6, 1, 7, 9]
        ]
        
        // 随机打乱数字（1-9）
        var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        numbers.shuffle()
        
        // 使用打乱的数字替换解决方案中的数字
        for row in 0..<9 {
            for col in 0..<9 {
                if solution[row][col] > 0 {
                    board[row][col] = numbers[solution[row][col] - 1]
                }
            }
        }
        
        // 简单变换进一步随机化（行/列交换）
        shuffleRows()
        shuffleColumns()
    }
    
    // 在同一个3x3区域内随机交换行
    private func shuffleRows() {
        for blockIndex in 0..<3 {
            let blockStart = blockIndex * 3
            var rows = [blockStart, blockStart + 1, blockStart + 2]
            rows.shuffle()
            
            let tempBoard = board
            for i in 0..<3 {
                board[blockStart + i] = tempBoard[rows[i]]
            }
        }
    }
    
    // 在同一个3x3区域内随机交换列
    private func shuffleColumns() {
        for blockIndex in 0..<3 {
            let blockStart = blockIndex * 3
            var cols = [blockStart, blockStart + 1, blockStart + 2]
            cols.shuffle()
            
            let tempBoard = board
            for row in 0..<9 {
                for i in 0..<3 {
                    board[row][blockStart + i] = tempBoard[row][cols[i]]
                }
            }
        }
    }
    
    // 检查棋盘是否有效
    func isBoardValid() -> Bool {
        // 检查行
        for row in 0..<9 {
            var seen = Set<Int>()
            for col in 0..<9 {
                let value = board[row][col]
                if value > 0 {
                    if seen.contains(value) {
                        return false
                    }
                    seen.insert(value)
                }
            }
        }
        
        // 检查列
        for col in 0..<9 {
            var seen = Set<Int>()
            for row in 0..<9 {
                let value = board[row][col]
                if value > 0 {
                    if seen.contains(value) {
                        return false
                    }
                    seen.insert(value)
                }
            }
        }
        
        // 检查3x3区块
        for blockRow in 0..<3 {
            for blockCol in 0..<3 {
                var seen = Set<Int>()
                for row in 0..<3 {
                    for col in 0..<3 {
                        let value = board[blockRow * 3 + row][blockCol * 3 + col]
                        if value > 0 {
                            if seen.contains(value) {
                                return false
                            }
                            seen.insert(value)
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    // 检查棋盘是否完成
    func isBoardComplete() -> Bool {
        // 先检查是否有效
        if !isBoardValid() {
            return false
        }
        
        // 检查是否所有单元格都已填充
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] == 0 {
                    return false
                }
            }
        }
        
        return true
    }
    
    // 获取一个提示（查找一个可以填充的安全单元格）
    func getHint() -> (row: Int, col: Int, value: Int)? {
        // 找到一个空单元格
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] == 0 {
                    // 尝试找到一个安全的数字
                    for value in 1...9 {
                        if isSafe(row: row, col: col, value: value) {
                            return (row, col, value)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    // 检查在给定位置放置数字是否安全
    private func isSafe(row: Int, col: Int, value: Int) -> Bool {
        // 检查行
        for c in 0..<9 {
            if board[row][c] == value {
                return false
            }
        }
        
        // 检查列
        for r in 0..<9 {
            if board[r][col] == value {
                return false
            }
        }
        
        // 检查3x3方块
        let blockRow = (row / 3) * 3
        let blockCol = (col / 3) * 3
        for r in 0..<3 {
            for c in 0..<3 {
                if board[blockRow + r][blockCol + c] == value {
                    return false
                }
            }
        }
        
        return true
    }
}

// 预览
struct SudokuView_Previews: PreviewProvider {
    static var previews: some View {
        SudokuView()
    }
} 