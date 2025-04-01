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
                    
                    // 游戏区域和控制区布局
                    HStack(alignment: .top, spacing: 10) {
                        // 游戏区域
                        TetrisGameView(gameModel: gameModel)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(CGFloat(gameModel.width) / CGFloat(gameModel.height), contentMode: .fit)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        // 侧边控制区
                        VStack(spacing: 20) {
                            // 下一个方块预览
                            NextBlockView(block: gameModel.nextBlock, cellSize: 15)
                                .padding(.top, 10)
                            
                            // 游戏控制按钮
                            if gameModel.state == .playing {
                                Button(action: { gameModel.togglePause() }) {
                                    VStack {
                                        Image(systemName: "pause.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(Circle().fill(Color.orange))
                                    }
                                }
                                
                                Button(action: { gameModel.startGame() }) {
                                    VStack {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(Circle().fill(Color.red))
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(width: 80)
                    }
                    .padding(.horizontal)
                    
                    // 方向控制按钮（类似游戏机）
                    if gameModel.state == .playing {
                        VStack(spacing: 10) {
                            // 旋转按钮
                            HStack {
                                Spacer()
                                
                                Button(action: { gameModel.rotate() }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 60, height: 60)
                                            .shadow(radius: 3)
                                        
                                        Image(systemName: "arrow.2.squarepath")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(GameButtonStyle())
                                
                                Spacer()
                            }
                            
                            // 左右下移动按钮
                            HStack(spacing: 30) {
                                // 左移按钮
                                Button(action: { gameModel.moveLeft() }) {
                                    DirectionButtonView(direction: "left")
                                }
                                .buttonStyle(GameButtonStyle())
                                
                                // 下移按钮
                                Button(action: { 
                                    // 长按时硬着陆，短按时软下落
                                    gameModel.softDrop() 
                                }) {
                                    DirectionButtonView(direction: "down")
                                }
                                .buttonStyle(GameButtonStyle())
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            gameModel.hardDrop()
                                        }
                                )
                                
                                // 右移按钮
                                Button(action: { gameModel.moveRight() }) {
                                    DirectionButtonView(direction: "right")
                                }
                                .buttonStyle(GameButtonStyle())
                            }
                            .padding(.vertical, 10)
                            
                            // 硬下落按钮
                            Button(action: { gameModel.hardDrop() }) {
                                Text("硬着陆")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.red)
                                    )
                                    .shadow(radius: 2)
                            }
                            .buttonStyle(GameButtonStyle())
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.1))
                        )
                        .padding(.horizontal)
                    } else {
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
                    }
                    
                    // 控制说明（仅在游戏中状态显示）
                    if gameModel.state == .playing {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("触屏控制:")
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
                            
                            Spacer()
                        }
                        .padding()
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

// 游戏按钮样式
struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// 方向按钮视图
struct DirectionButtonView: View {
    let direction: String // "left", "right", "down"
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 70, height: 70)
                .shadow(radius: 3)
            
            Image(systemName: "arrow.\(direction)")
                .font(.title)
                .foregroundColor(.white)
        }
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
            Text("下一个")
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
                                    .overlay(
                                        Rectangle()
                                            .stroke(lineWidth: 0.5)
                                            .foregroundColor(Color.black.opacity(0.3))
                                    )
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