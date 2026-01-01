// Views/BubbleDialView.swift
import SwiftUI
import Combine

class BubbleDialViewModel: ObservableObject {
    @Published var tapCount: Int = 0
    @Published var bubbleOpacity: Double = 1.0
    
    func incrementCount() {
        tapCount += 1
        bubbleOpacity = 0.8
        
        HapticManager.shared.playClick()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.bubbleOpacity = 1.0
            }
        }
    }
    
    func resetCount() {
        tapCount = 0
    }
}

struct BubbleDialView: View {
    @ObservedObject var viewModel: BubbleDialViewModel
    @State private var particlePositions: [CGPoint] = []
    @State private var particleSizes: [CGFloat] = []
    @State private var particleColors: [Color] = []
    @State private var lastUpdateTime: Date = Date()
    
    let size: CGFloat = 120
    
    // 颜色定义
    private let bubbleColor = Color(red: 0.2, green: 0.8, blue: 1.0)      // 数字颜色
    private let darkBubbleColor = Color(red: 0.1, green: 0.4, blue: 0.5) // 微粒颜色（更暗）
    private let highlightColor = Color(red: 0.4, green: 0.95, blue: 1.0)
    
    // 安全区域（避免中心数字区域）
    private var safeMinRadius: CGFloat { size * 0.25 }  // 中心保留25%半径给数字
    private var safeMaxRadius: CGFloat { size * 0.45 } // 避免边界
    
    init(viewModel: BubbleDialViewModel = BubbleDialViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            // 背景 - 修改为与主背景不同的深蓝色渐变
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.08, green: 0.12, blue: 0.25),  // 比主背景稍亮
                            Color(red: 0.04, green: 0.06, blue: 0.15)   // 深蓝色
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size/2
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    bubbleColor.opacity(0.5),
                                    highlightColor.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .clipShape(Circle())
            
            // 气泡粒子 - 颜色比数字暗
            ForEach(0..<viewModel.tapCount, id: \.self) { index in
                if index < particlePositions.count && index < particleSizes.count && index < particleColors.count {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    particleColors[index].opacity(0.7),
                                    particleColors[index].opacity(0.4)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: particleSizes[index] / 2
                            )
                        )
                        .frame(width: particleSizes[index], height: particleSizes[index])
                        .position(particlePositions[index])
                        .shadow(color: particleColors[index].opacity(0.3), radius: 2, x: 0, y: 0)
                }
            }
            
            // 点击次数显示 - 在微粒之上，确保不被覆盖
            Text("\(viewModel.tapCount)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(bubbleColor)
                .shadow(color: bubbleColor.opacity(0.5), radius: 8, x: 0, y: 0)
                .zIndex(1) // 确保数字在微粒之上
            
            // 重置按钮（长按）
            .onLongPressGesture(minimumDuration: 1.0) {
                resetParticles()
                viewModel.resetCount()
                HapticManager.shared.playClick()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            bubbleColor.opacity(0.3),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .onTapGesture {
            handleTap()
        }
        .onChange(of: viewModel.tapCount) { newValue in
            // 确保微粒数量与点击次数相同
            updateParticles(count: newValue)
        }
        .onAppear {
            // 初始化粒子
            updateParticles(count: viewModel.tapCount)
        }
        .opacity(viewModel.bubbleOpacity)
    }
    
    private func handleTap() {
        let now = Date()
        // 防止点击过快
        if now.timeIntervalSince(lastUpdateTime) > 0.1 {
            lastUpdateTime = now
            viewModel.incrementCount()
        }
    }
    
    // 生成安全区域内的随机位置，纯随机分布
    private func generateRandomPosition() -> CGPoint {
        let center = CGPoint(x: size / 2, y: size / 2)
        
        // 使用极坐标随机生成位置
        let radius = CGFloat.random(in: safeMinRadius...safeMaxRadius)
        let angle = Double.random(in: 0..<360) * Double.pi / 180
        
        let position = CGPoint(
            x: center.x + radius * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(sin(angle))
        )
        
        return position
    }
    
    // 生成随机颜色，比数字颜色暗
    private func generateRandomColor() -> Color {
        // 在暗色气泡颜色的基础上进行随机微调
        let hueVariation = Double.random(in: -0.05...0.05)  // 色调微调
        let saturationVariation = Double.random(in: -0.1...0.1)  // 饱和度微调
        let brightnessVariation = Double.random(in: -0.1...0)  // 亮度比基础颜色暗
        
        let baseHue: Double = 200.0 / 360.0  // 青蓝色基调
        let baseSaturation: Double = 0.7
        let baseBrightness: Double = 0.5
        
        return Color(
            hue: max(0, min(1, baseHue + hueVariation)),
            saturation: max(0.4, min(0.9, baseSaturation + saturationVariation)),
            brightness: max(0.3, min(0.6, baseBrightness + brightnessVariation))
        )
    }
    
    private func updateParticles(count: Int) {
        let center = CGPoint(x: size / 2, y: size / 2)
        
        // 确保粒子数量等于点击次数
        if count > particlePositions.count {
            // 需要添加更多粒子
            let newParticleCount = count - particlePositions.count
            for _ in 0..<newParticleCount {
                // 纯随机位置
                let position = generateRandomPosition()
                
                // 随机大小（6-12像素）
                let size = CGFloat.random(in: 6...12)
                
                // 随机颜色（比数字颜色暗）
                let color = generateRandomColor()
                
                particlePositions.append(position)
                particleSizes.append(size)
                particleColors.append(color)
            }
        } else if count < particlePositions.count {
            // 需要移除粒子（重置时）
            particlePositions.removeLast(particlePositions.count - count)
            particleSizes.removeLast(particleSizes.count - count)
            particleColors.removeLast(particleColors.count - count)
        }
    }
    
    private func resetParticles() {
        withAnimation(.easeOut(duration: 0.3)) {
            particlePositions.removeAll()
            particleSizes.removeAll()
            particleColors.removeAll()
        }
    }
}
