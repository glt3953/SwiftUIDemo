import Foundation
import Combine
import SwiftUI

// 方块类型
enum BlockType: CaseIterable {
    case i, j, l, o, s, t, z
    
    var color: Color {
        switch self {
        case .i: return .blue
        case .j: return .orange
        case .l: return .purple
        case .o: return .yellow
        case .s: return .green
        case .t: return .pink
        case .z: return .red
        }
    }
    
    var shape: [[Bool]] {
        switch self {
        case .i:
            return [
                [false, false, false, false],
                [true, true, true, true],
                [false, false, false, false],
                [false, false, false, false]
            ]
        case .j:
            return [
                [true, false, false],
                [true, true, true],
                [false, false, false]
            ]
        case .l:
            return [
                [false, false, true],
                [true, true, true],
                [false, false, false]
            ]
        case .o:
            return [
                [true, true],
                [true, true]
            ]
        case .s:
            return [
                [false, true, true],
                [true, true, false],
                [false, false, false]
            ]
        case .t:
            return [
                [false, true, false],
                [true, true, true],
                [false, false, false]
            ]
        case .z:
            return [
                [true, true, false],
                [false, true, true],
                [false, false, false]
            ]
        }
    }
}

// 游戏区块
struct Block {
    var type: BlockType
    var x: Int
    var y: Int
    var rotation: Int = 0
    
    var cells: [[Bool]] {
        let shape = type.shape
        var rotatedShape = shape
        
        // 旋转方块
        for _ in 0..<rotation {
            rotatedShape = rotateClockwise(rotatedShape)
        }
        
        return rotatedShape
    }
    
    private func rotateClockwise(_ shape: [[Bool]]) -> [[Bool]] {
        let size = shape.count
        var result = Array(repeating: Array(repeating: false, count: size), count: size)
        
        for i in 0..<size {
            for j in 0..<size {
                result[j][size - 1 - i] = shape[i][j]
            }
        }
        
        return result
    }
    
    func offsetBy(dx: Int, dy: Int) -> Block {
        var newBlock = self
        newBlock.x += dx
        newBlock.y += dy
        return newBlock
    }
    
    func rotated() -> Block {
        var newBlock = self
        newBlock.rotation = (rotation + 1) % 4
        return newBlock
    }
}

// 游戏状态
enum GameState {
    case idle
    case playing
    case paused
    case gameOver
}

// 游戏模型
class TetrisGameModel: ObservableObject {
    // 游戏区域尺寸
    let width = 10
    let height = 20
    
    // 游戏状态
    @Published var state: GameState = .idle
    
    // 方块数据
    @Published var grid: [[BlockType?]]
    @Published var currentBlock: Block?
    @Published var nextBlock: Block
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var lines: Int = 0
    
    // 游戏计时器
    private var timer: AnyCancellable?
    private var dropSpeed: TimeInterval = 1.0
    
    init() {
        // 初始化空游戏区
        grid = Array(repeating: Array(repeating: nil, count: width), count: height)
        
        // 创建第一个方块
        nextBlock = Self.createNewBlock(width: width)
        
        // 预置颜色主题
        Self.setupGameAppearance()
    }
    
    // 开始新游戏
    func startGame() {
        // 重置游戏状态
        grid = Array(repeating: Array(repeating: nil, count: width), count: height)
        score = 0
        level = 1
        lines = 0
        dropSpeed = 1.0
        state = .playing
        
        // 创建下一个方块
        spawnNewBlock()
        
        // 设置计时器
        setupTimer()
    }
    
    // 暂停/继续游戏
    func togglePause() {
        if state == .playing {
            state = .paused
            timer?.cancel()
        } else if state == .paused {
            state = .playing
            setupTimer()
        }
    }
    
    // 方块移动
    func moveLeft() {
        guard state == .playing, let currentBlock = currentBlock else { return }
        let newBlock = currentBlock.offsetBy(dx: -1, dy: 0)
        if isValidPosition(for: newBlock) {
            self.currentBlock = newBlock
        }
    }
    
    func moveRight() {
        guard state == .playing, let currentBlock = currentBlock else { return }
        let newBlock = currentBlock.offsetBy(dx: 1, dy: 0)
        if isValidPosition(for: newBlock) {
            self.currentBlock = newBlock
        }
    }
    
    func rotate() {
        guard state == .playing, let currentBlock = currentBlock else { return }
        let newBlock = currentBlock.rotated()
        if isValidPosition(for: newBlock) {
            self.currentBlock = newBlock
        }
    }
    
    func dropDown() {
        guard state == .playing else { return }
        hardDrop()
    }
    
    // 硬着陆（快速下落）
    func hardDrop() {
        guard state == .playing, let currentBlock = currentBlock else { return }
        var newBlock = currentBlock
        
        while isValidPosition(for: newBlock.offsetBy(dx: 0, dy: 1)) {
            newBlock = newBlock.offsetBy(dx: 0, dy: 1)
        }
        
        self.currentBlock = newBlock
        landBlock()
    }
    
    // 软着陆（普通下落）
    func softDrop() {
        guard state == .playing, let currentBlock = currentBlock else { return }
        let newBlock = currentBlock.offsetBy(dx: 0, dy: 1)
        
        if isValidPosition(for: newBlock) {
            self.currentBlock = newBlock
        } else {
            landBlock()
        }
    }
    
    // 设置计时器
    private func setupTimer() {
        timer?.cancel()
        
        timer = Timer.publish(every: dropSpeed, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.softDrop()
            }
    }
    
    // 更新下落速度
    private func updateSpeed() {
        dropSpeed = max(0.1, 1.0 - (Double(level - 1) * 0.1))
        setupTimer()
    }
    
    // 生成新方块
    private func spawnNewBlock() {
        currentBlock = nextBlock
        nextBlock = Self.createNewBlock(width: width)
        
        // 检查游戏是否结束
        if currentBlock != nil && !isValidPosition(for: currentBlock!) {
            state = .gameOver
            timer?.cancel()
        }
    }
    
    // 创建新方块
    private static func createNewBlock(width: Int) -> Block {
        let randomType = BlockType.allCases.randomElement()!
        let x = width / 2 - 1
        return Block(type: randomType, x: x, y: 0)
    }
    
    // 方块着陆
    private func landBlock() {
        guard let currentBlock = currentBlock else { return }
        
        // 将方块添加到网格
        let shape = currentBlock.cells
        let blockHeight = shape.count
        let blockWidth = shape[0].count
        
        for i in 0..<blockHeight {
            for j in 0..<blockWidth {
                if shape[i][j] {
                    let gridX = currentBlock.x + j
                    let gridY = currentBlock.y + i
                    
                    // 确保在有效范围内
                    if gridY >= 0 && gridY < height && gridX >= 0 && gridX < width {
                        grid[gridY][gridX] = currentBlock.type
                    }
                }
            }
        }
        
        // 清除已完成的行
        clearLines()
        
        // 生成新方块
        spawnNewBlock()
    }
    
    // 清除已完成的行
    private func clearLines() {
        var linesCleared = 0
        
        for y in 0..<height {
            // 检查一整行是否已填满
            if grid[y].allSatisfy({ $0 != nil }) {
                // 移除该行
                grid.remove(at: y)
                // 添加一行空行到顶部
                grid.insert(Array(repeating: nil, count: width), at: 0)
                linesCleared += 1
            }
        }
        
        // 更新分数
        if linesCleared > 0 {
            updateScore(linesCleared: linesCleared)
        }
    }
    
    // 更新分数
    private func updateScore(linesCleared: Int) {
        // 根据消除的行数更新分数
        let basePoints = [40, 100, 300, 1200] // 1, 2, 3, 4行的基础分数
        let linePoints = basePoints[min(linesCleared, 4) - 1] * level
        
        score += linePoints
        lines += linesCleared
        
        // 每10行升一级
        if lines / 10 + 1 > level {
            level = lines / 10 + 1
            updateSpeed()
        }
    }
    
    // 检查位置是否有效
    private func isValidPosition(for block: Block) -> Bool {
        let shape = block.cells
        let blockHeight = shape.count
        let blockWidth = shape[0].count
        
        for i in 0..<blockHeight {
            for j in 0..<blockWidth {
                if shape[i][j] {
                    let gridX = block.x + j
                    let gridY = block.y + i
                    
                    // 检查边界
                    if gridX < 0 || gridX >= width || gridY >= height {
                        return false
                    }
                    
                    // 检查碰撞（不检查y<0的部分，允许新方块从顶部生成）
                    if gridY >= 0 && grid[gridY][gridX] != nil {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    // 设置游戏外观
    private static func setupGameAppearance() {
        // 这里可以设置一些全局UI的颜色主题
    }
} 