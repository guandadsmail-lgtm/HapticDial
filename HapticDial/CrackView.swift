
// Views/CrackView.swift
import SwiftUI
import CoreHaptics
import AudioToolbox

struct CrackView: View {
    @ObservedObject private var crackManager = CrackManager.shared
    @State private var particleSystem = CrackParticleSystem()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 半透明黑色覆盖层，模拟玻璃效果
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .opacity(crackManager.crackOpacity * 0.8)
                    .blur(radius: 1)
                
                // 玻璃高光效果
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.05),
                        Color.clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(crackManager.crackOpacity * 0.6)
                
                // 粒子效果
                ForEach(particleSystem.particles) { particle in
                    CrackParticleView(particle: particle)
                        .opacity(crackManager.crackOpacity)
                }
                
                // 绘制所有裂纹
                ForEach(crackManager.cracks) { crack in
                    CrackLine(crack: crack, opacity: crackManager.crackOpacity)
                }
                
                // 破裂中心点的高光效果
                if let firstCrack = crackManager.cracks.first {
                    CrackCenterHighlight(position: firstCrack.startPoint)
                        .opacity(crackManager.crackOpacity)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .allowsHitTesting(false) // 允许点击穿透
            .onAppear {
                crackManager.setScreenSize(geometry.size)
                startParticleAnimation()
            }
            .onChange(of: crackManager.showCracks) { newValue in
                if newValue {
                    startParticleAnimation()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func startParticleAnimation() {
        particleSystem.reset()
        
        // 生成破裂粒子
        if let firstCrack = crackManager.cracks.first {
            for _ in 0..<30 {
                let angle = Double.random(in: 0..<360)
                let distance = CGFloat.random(in: 0...60)
                let x = firstCrack.startPoint.x + distance * CGFloat(cos(angle * .pi / 180))
                let y = firstCrack.startPoint.y + distance * CGFloat(sin(angle * .pi / 180))
                
                particleSystem.addParticle(at: CGPoint(x: x, y: y))
            }
        }
    }
}

// 单个裂纹线
struct CrackLine: View {
    let crack: Crack
    let opacity: Double
    
    var body: some View {
        Path { path in
            // 计算当前动画位置
            let progress = crack.animationProgress
            let currentX = crack.startPoint.x + (crack.endPoint.x - crack.startPoint.x) * CGFloat(progress)
            let currentY = crack.startPoint.y + (crack.endPoint.y - crack.startPoint.y) * CGFloat(progress)
            
            path.move(to: crack.startPoint)
            
            // 添加一些微小的随机抖动，使裂纹看起来更自然
            let segments = 10
            for i in 1...segments {
                let segmentProgress = CGFloat(i) / CGFloat(segments) * progress
                let segmentX = crack.startPoint.x + (crack.endPoint.x - crack.startPoint.x) * segmentProgress
                let segmentY = crack.startPoint.y + (crack.endPoint.y - crack.startPoint.y) * segmentProgress
                
                let jitterAmount: CGFloat = crack.depth == 1 ? 0.8 : 0.3
                let jitterX = CGFloat.random(in: -jitterAmount...jitterAmount)
                let jitterY = CGFloat.random(in: -jitterAmount...jitterAmount)
                
                if i == 1 {
                    path.addLine(to: CGPoint(x: segmentX + jitterX, y: segmentY + jitterY))
                } else {
                    path.addLine(to: CGPoint(x: segmentX, y: segmentY))
                }
            }
            
            path.addLine(to: CGPoint(x: currentX, y: currentY))
        }
        .stroke(
            CrackGradient(depth: crack.depth),
            style: StrokeStyle(
                lineWidth: crack.thickness,
                lineCap: .round,
                lineJoin: .round,
                miterLimit: 0,
                dash: crack.depth > 1 ? [3, 2] : [],
                dashPhase: 0
            )
        )
        .shadow(color: Color.white.opacity(0.4), radius: crack.depth == 1 ? 2 : 1, x: 0, y: 0)
        .shadow(color: Color.black.opacity(0.3), radius: crack.depth == 1 ? 3 : 1, x: 0, y: 0)
        .opacity(opacity)
    }
}

// 裂纹渐变颜色
struct CrackGradient: ShapeStyle {
    let depth: Int
    
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        switch depth {
        case 1: // 主裂纹 - 白色带蓝色边缘
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.95),
                    Color.white.opacity(0.9),
                    Color(red: 0.7, green: 0.9, blue: 1.0).opacity(0.8),
                    Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.6)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case 2: // 二级裂纹 - 淡蓝色
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.95, blue: 1.0).opacity(0.9),
                    Color(red: 0.4, green: 0.85, blue: 1.0).opacity(0.7),
                    Color(red: 0.2, green: 0.7, blue: 0.9).opacity(0.5)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        default: // 三级裂纹 - 淡灰色
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.95, blue: 1.0).opacity(0.8),
                    Color.gray.opacity(0.6),
                    Color.gray.opacity(0.4)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// 破裂中心点的高光效果
struct CrackCenterHighlight: View {
    let position: CGPoint
    
    var body: some View {
        ZStack {
            // 中心亮点
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .white,
                            Color(red: 0.9, green: 0.95, blue: 1.0).opacity(0.8),
                            Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.3),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .position(position)
                .blur(radius: 2)
            
            // 光晕效果
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.4),
                            Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.1),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .position(position)
                .blur(radius: 8)
            
            // 脉动效果
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.9),
                            Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 40, height: 40)
                .position(position)
                .blur(radius: 1)
        }
    }
}

// 粒子系统
class CrackParticleSystem: ObservableObject {
    @Published var particles: [CrackParticle] = []
    private var timer: Timer?
    
    func reset() {
        particles.removeAll()
        timer?.invalidate()
    }
    
    func addParticle(at position: CGPoint) {
        let particle = CrackParticle(
            id: UUID(),
            position: position,
            velocity: CGPoint(
                x: CGFloat.random(in: -3...3),
                y: CGFloat.random(in: -3...3)
            ),
            size: CGFloat.random(in: 1...3),
            opacity: Double.random(in: 0.5...0.9),
            lifeTime: Double.random(in: 0.5...2.0)
        )
        particles.append(particle)
        
        startAnimation()
    }
    
    private func startAnimation() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            for i in self.particles.indices {
                self.particles[i].lifeTime -= 0.03
                
                if self.particles[i].lifeTime > 0 {
                    self.particles[i].position.x += self.particles[i].velocity.x
                    self.particles[i].position.y += self.particles[i].velocity.y
                    
                    // 逐渐减小
                    self.particles[i].size = max(0.1, self.particles[i].size * 0.98)
                    self.particles[i].opacity = max(0, self.particles[i].opacity * 0.97)
                    
                    // 减速
                    self.particles[i].velocity.x *= 0.95
                    self.particles[i].velocity.y *= 0.95
                }
            }
            
            // 移除生命周期结束的粒子
            self.particles.removeAll { $0.lifeTime <= 0 }
            
            if self.particles.isEmpty {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
}

// 粒子模型
struct CrackParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    var velocity: CGPoint
    var size: CGFloat
    var opacity: Double
    var lifeTime: Double
}

// 粒子视图
struct CrackParticleView: View {
    let particle: CrackParticle
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.9),
                        Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.6),
                        .clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size)
            .position(particle.position)
            .opacity(particle.opacity)
            .blur(radius: 0.5)
    }
}
