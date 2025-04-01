import SwiftUI

struct TetrisView: View {
    @StateObject private var gameModel = TetrisGameModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    // 游戏信息
                    GameInfoView(gameModel: gameModel)
                    
                    // 游戏区域
                    TetrisGameView(gameModel: gameModel)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(CGFloat(gameModel.width) / CGFloat(gameModel.height), contentMode: .fit)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    
                    HStack {
                        // 下一个方块预览
                        NextBlockView(block: gameModel.nextBlock, cellSize: 20)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        // 游戏控制按钮
                        if gameModel.state == .playing {
                            HStack(spacing: 15) {
                                // 暂停按钮
                                Button(action: { gameModel.togglePause() }) {
                                    Image(systemName: "pause.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Circle().fill(Color.orange))
                                }
                                
                                // 重置按钮
                                Button(action: { gameModel.startGame() }) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Circle().fill(Color.red))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    if gameModel.state != .playing {
                        // 开始按钮（仅在非游戏中状态显示）
                        Button(action: {
                            if gameModel.state == .paused {
                                gameModel.togglePause()
                            } else {
                                gameModel.startGame()
                            }
                        }) {
                            Text(gameModel.state == .paused ? "继续游戏" : "开始游戏")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(minWidth: 150)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                )
                        }
                        .padding(.top, 10)
                    } else {
                        // 控制说明（仅在游戏中状态显示）
                        VStack(alignment: .leading, spacing: 5) {
                            Text("操作说明:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("• 点击: 旋转")
                                .font(.caption)
                            Text("• 左/右滑动: 移动方块")
                                .font(.caption)
                            Text("• 下滑: 加速下落")
                                .font(.caption)
                            Text("• 长按: 快速下落")
                                .font(.caption)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray5))
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("俄罗斯方块")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // 背景渐变
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color.black : Color(.systemGray6),
                colorScheme == .dark ? Color(.systemGray6) : Color.white
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// 游戏信息视图
struct GameInfoView: View {
    @ObservedObject var gameModel: TetrisGameModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("分数: \(gameModel.score)")
                    .font(.headline)
                Text("等级: \(gameModel.level)")
                    .font(.subheadline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("行数: \(gameModel.lines)")
                    .font(.headline)
            }
        }
        .padding(.horizontal)
    }
}

// 下一个方块预览
struct NextBlockView: View {
    let block: Block
    let cellSize: CGFloat
    
    var body: some View {
        VStack(spacing: 5) {
            Text("下一个方块")
                .font(.headline)
            
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
                    .frame(width: cellSize * 6, height: cellSize * 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                
                // 方块
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
                                        x: CGFloat(j) * cellSize + (6 - CGFloat(blockWidth)) * cellSize / 2,
                                        y: CGFloat(i) * cellSize + (6 - CGFloat(blockHeight)) * cellSize / 2
                                    )
                            }
                        }
                    }
                }
            }
            .frame(width: cellSize * 6, height: cellSize * 6)
        }
    }
}

#Preview {
    TetrisView()
} 