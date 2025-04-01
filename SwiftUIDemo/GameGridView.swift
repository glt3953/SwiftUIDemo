import SwiftUI

struct GameGridView: View {
    @ObservedObject var gameModel: TetrisGameModel
    let cellSize: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // 背景图案
            gridBackgroundPattern
            
            // 游戏网格
            VStack(spacing: 0) {
                ForEach(0..<gameModel.height, id: \.self) { y in
                    HStack(spacing: 0) {
                        ForEach(0..<gameModel.width, id: \.self) { x in
                            Rectangle()
                                .fill(cellColor(at: x, y: y))
                                .frame(width: cellSize, height: cellSize)
                                .overlay(
                                    Rectangle()
                                        .stroke(lineWidth: 0.5)
                                        .foregroundColor(Color.black.opacity(0.2))
                                )
                        }
                    }
                }
            }
            
            // 游戏边框
            Rectangle()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: CGFloat(gameModel.width) * cellSize, 
                       height: CGFloat(gameModel.height) * cellSize)
        }
    }
    
    // 网格背景图案
    private var gridBackgroundPattern: some View {
        Rectangle()
            .fill(
                colorScheme == .dark ? 
                    Color(.systemGray6).opacity(0.1) : 
                    Color(.systemGray5).opacity(0.2)
            )
            .overlay(
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let gridSize = cellSize
                        
                        // 垂直线
                        for i in 0...gameModel.width {
                            let x = CGFloat(i) * gridSize
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: height))
                        }
                        
                        // 水平线
                        for j in 0...gameModel.height {
                            let y = CGFloat(j) * gridSize
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                    }
                    .stroke(
                        colorScheme == .dark ? 
                            Color.white.opacity(0.05) : 
                            Color.black.opacity(0.05),
                        lineWidth: 1
                    )
                }
            )
    }
    
    // 单元格颜色
    private func cellColor(at x: Int, y: Int) -> Color {
        if let blockType = gameModel.grid[y][x] {
            return blockType.color
        }
        return colorScheme == .dark ? 
            Color(.systemGray6).opacity(0.3) : 
            Color(.systemGray6)
    }
}

// 方块视图
struct BlockView: View {
    let block: Block
    let cellSize: CGFloat
    let gameWidth: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let cells = block.cells
        let blockHeight = cells.count
        let blockWidth = cells[0].count
        
        ZStack {
            ForEach(0..<blockHeight, id: \.self) { i in
                ForEach(0..<blockWidth, id: \.self) { j in
                    if cells[i][j] {
                        Rectangle()
                            .fill(block.type.color)
                            .frame(width: cellSize, height: cellSize)
                            .overlay(
                                Rectangle()
                                    .stroke(lineWidth: 0.5)
                                    .foregroundColor(Color.black.opacity(0.3))
                            )
                            .position(
                                x: CGFloat(block.x + j) * cellSize + cellSize / 2,
                                y: CGFloat(block.y + i) * cellSize + cellSize / 2
                            )
                    }
                }
            }
        }
        .frame(width: CGFloat(gameWidth) * cellSize, height: CGFloat(gameWidth) * 2 * cellSize)
    }
} 