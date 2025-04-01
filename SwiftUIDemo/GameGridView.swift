import SwiftUI

struct GameGridView: View {
    @ObservedObject var gameModel: TetrisGameModel
    let cellSize: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<gameModel.height, id: \.self) { y in
                HStack(spacing: 0) {
                    ForEach(0..<gameModel.width, id: \.self) { x in
                        Rectangle()
                            .fill(cellColor(at: x, y: y))
                            .frame(width: cellSize, height: cellSize)
                            .border(Color.black.opacity(0.2), width: 0.5)
                    }
                }
            }
        }
    }
    
    private func cellColor(at x: Int, y: Int) -> Color {
        if let blockType = gameModel.grid[y][x] {
            return blockType.color
        }
        return Color(.systemGray6)
    }
}

// 方块视图
struct BlockView: View {
    let block: Block
    let cellSize: CGFloat
    let gameWidth: Int
    
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
                            .border(Color.white.opacity(0.2), width: 1)
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