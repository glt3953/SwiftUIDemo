import SwiftUI

struct LuckyWheelView: View {
    // 奖品等级
    let prizes = ["一等奖", "二等奖", "三等奖", "幸运奖"]
    // 奖品颜色
    let colors: [Color] = [.red, .blue, .green, .orange]
    // 奖品占比角度 (总和为360度)
    let prizeAngles: [Double] = [30, 60, 90, 180]
    
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var result: String = ""
    @State private var showResult = false
    
    var body: some View {
        VStack {
            Text("转盘抽奖")
                .font(.largeTitle)
                .padding()
            
            ZStack {
                // 转盘
                WheelView(
                    prizes: prizes,
                    colors: colors,
                    angles: prizeAngles,
                    rotation: rotation
                )
                .frame(width: 300, height: 300)
                
                // 指针 (固定不动)
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.yellow)
                    .offset(y: -170)
                    .zIndex(1)
            }
            .padding()
            
            Button(action: {
                if !isSpinning {
                    spinWheel()
                }
            }) {
                Text("开始抽奖")
                    .font(.title)
                    .padding()
                    .background(isSpinning ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isSpinning)
            .padding()
        }
        .alert("恭喜获得", isPresented: $showResult) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(result)
        }
    }
    
    func spinWheel() {
        isSpinning = true
        
        // 随机抽奖，根据概率确定结果
        let randomValue = Double.random(in: 0..<360) // 修改为0..<360避免边界值问题
        var currentAngle: Double = 0
        var selectedIndex = 0
        
        for (index, angle) in prizeAngles.enumerated() {
            if randomValue >= currentAngle && randomValue < currentAngle + angle {
                selectedIndex = index
                break
            }
            currentAngle += angle
        }
        
        // 确保总是能找到一个奖项，即使在边界情况下
        if selectedIndex == 0 && randomValue >= 360 {
            // 如果随机值超过360度，则选择第一个奖项
            selectedIndex = 0
        } else if selectedIndex == 0 && randomValue >= currentAngle {
            // 如果循环结束后没有找到匹配项，则选择最后一个奖项
            selectedIndex = prizeAngles.count - 1
        }
        
        result = prizes[selectedIndex]
        
        // 计算旋转角度，让指针指向选中的奖项
        // 计算所选奖品的中心角度
        var centerAngle: Double = 0
        for i in 0..<selectedIndex {
            centerAngle += prizeAngles[i]
        }
        centerAngle += prizeAngles[selectedIndex] / 2
        
        // 基础旋转5圈，然后加上额外的角度指向特定奖项
        // 由于指针在顶部，需要调整角度计算
        // 确保指针停在奖项中心位置
        let targetAngle = 360.0 * 5 + (360 - centerAngle)
        
        withAnimation(.easeInOut(duration: 3)) {
            rotation += targetAngle
        }
        
        // 旋转结束后显示结果
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            showResult = true
            isSpinning = false
        }
    }
}

// 转盘视图
struct WheelView: View {
    let prizes: [String]
    let colors: [Color]
    let angles: [Double]
    let rotation: Double
    
    var body: some View {
        ZStack {
            // 绘制扇形
            ForEach(0..<prizes.count, id: \.self) { index in
                PrizeSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: colors[index % colors.count],
                    text: prizes[index],
                    textAngle: textRotation(for: index)
                )
            }
        }
        .rotationEffect(.degrees(rotation))
    }
    
    // 计算每个扇形的起始角度
    func startAngle(for index: Int) -> Angle {
        var angle: Double = 0
        for i in 0..<index {
            angle += angles[i]
        }
        return .degrees(angle)
    }
    
    // 计算每个扇形的结束角度
    func endAngle(for index: Int) -> Angle {
        return .degrees(startAngle(for: index).degrees + angles[index])
    }
    
    // 计算文字的旋转角度，使其位于扇形中央
    func textRotation(for index: Int) -> Angle {
        let startDegrees = startAngle(for: index).degrees
        return .degrees(startDegrees + angles[index] / 2)
    }
}

// 转盘奖品扇形
struct PrizeSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let text: String
    let textAngle: Angle
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                // 绘制扇形
                Path { path in
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    path.move(to: center)
                    path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    path.closeSubpath()
                }
                .fill(color)
                
                // 奖品文字
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .rotationEffect(textAngle, anchor: .center)
                    .offset(y: -radius * 0.4) // 根据扇形半径动态计算文字偏移量
            }
        }
    }
}

struct LuckyWheelView_Previews: PreviewProvider {
    static var previews: some View {
        LuckyWheelView()
    }
}
