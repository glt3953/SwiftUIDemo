import SwiftUI

struct TetrisGameView: View {
    @ObservedObject var gameModel: TetrisGameModel
    
    // 手势状态
    @State private var dragOffset: CGSize = .zero
    @State private var dragStartLocation: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 游戏网格
                GameGridView(gameModel: gameModel, cellSize: calculateCellSize(geometry: geometry))
                
                // 当前方块
                if let currentBlock = gameModel.currentBlock {
                    BlockView(
                        block: currentBlock,
                        cellSize: calculateCellSize(geometry: geometry),
                        gameWidth: gameModel.width
                    )
                }
                
                // 游戏状态叠加层（如暂停、游戏结束等）
                if gameModel.state != .playing {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    // 根据游戏状态显示不同的信息
                    gameStateOverlayView
                }
            }
            .contentShape(Rectangle()) // 使整个区域可以接收手势
            .gesture(
                // 拖动手势用于左右移动和下落
                DragGesture()
                    .onChanged { value in
                        // 仅在游戏进行中才响应手势
                        guard gameModel.state == .playing else { return }
                        
                        let threshold: CGFloat = 20 // 移动阈值
                        
                        // 保存开始拖动的位置
                        if dragOffset == .zero {
                            dragStartLocation = value.startLocation
                        }
                        
                        dragOffset = value.translation
                        
                        // 横向移动检测
                        if abs(dragOffset.width) > threshold && abs(dragOffset.height) < threshold {
                            if dragOffset.width > 0 {
                                gameModel.moveRight()
                            } else {
                                gameModel.moveLeft()
                            }
                            // 重置拖动偏移以便可以连续移动
                            dragOffset = .zero
                        }
                        
                        // 下落检测
                        if dragOffset.height > threshold && abs(dragOffset.width) < threshold {
                            gameModel.softDrop()
                            // 重置拖动偏移以便可以连续移动
                            dragOffset = .zero
                        }
                    }
                    .onEnded { _ in
                        // 重置拖动状态
                        dragOffset = .zero
                    }
            )
            .gesture(
                // 点击手势用于旋转
                TapGesture()
                    .onEnded {
                        // 仅在游戏进行中才响应手势
                        guard gameModel.state == .playing else { return }
                        gameModel.rotate()
                    }
            )
        }
        .aspectRatio(CGFloat(gameModel.width) / CGFloat(gameModel.height), contentMode: .fit)
    }
    
    // 游戏状态覆盖视图
    @ViewBuilder
    private var gameStateOverlayView: some View {
        VStack(spacing: 20) {
            switch gameModel.state {
            case .idle:
                Button(action: {
                    gameModel.startGame()
                }) {
                    VStack {
                        Text("点击开始")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
            case .paused:
                VStack {
                    Text("游戏暂停")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
            case .gameOver:
                VStack {
                    Text("游戏结束")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("分数: \(gameModel.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom)
                }
                
            default:
                EmptyView()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
        )
        .padding()
    }
    
    // 计算单元格大小以适应屏幕
    private func calculateCellSize(geometry: GeometryProxy) -> CGFloat {
        let width = geometry.size.width
        let height = geometry.size.height
        
        // 根据宽度或高度约束来计算单元格尺寸
        let widthConstrained = width / CGFloat(gameModel.width)
        let heightConstrained = height / CGFloat(gameModel.height)
        
        return min(widthConstrained, heightConstrained)
    }
} 