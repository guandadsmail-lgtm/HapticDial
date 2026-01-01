// Views/FireworksView.swift
import SwiftUI
import Combine

// 烟火状态
enum FireworkState {
    case launching   // 发射中
    case exploding   // 爆炸中
    case falling     // 下落中
    case finished    // 结束
}

// 烟火数据模型
class Firework: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    let mainColor: Color
    let size: CGFloat
    var opacity: Double
    var state: FireworkState
    var lifeTime: TimeInterval = 0
    let maxLifeTime: TimeInterval = 5.0
    
    init(position: CGPoint, velocity: CGPoint, color: Color, size: CGFloat = 10) {
        self.position = position
        self.velocity = velocity
        self.mainColor = color
        self.size = size
        self.opacity = 1.0
        self.state = .launching
    }
}

// 烟火粒子数据模型
class FireworkParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    var blur: CGFloat
    var lifeTime: TimeInterval = 0
    let maxLifeTime: TimeInterval = 3.0
    
    init(position: CGPoint, velocity: CGPoint, color: Color, size: CGFloat = 6) {
        self.position = position
        self.velocity = velocity
        self.color = color
        self.size = size
        self.opacity = 1.0
        self.blur = CGFloat.random(in: 0...3)
    }
}

// 闪光数据模型
class Flash: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    var size: CGFloat
    var opacity: Double
    var lifeTime: TimeInterval = 0
    let maxLifeTime: TimeInterval = 0.8
    
    init(position: CGPoint, color: Color, size: CGFloat = 120) {
        self.position = position
        self.color = color
        self.size = size
        self.opacity = 1.0
    }
}

// 烟火视图模型
class FireworksViewModel: ObservableObject {
    @Published var fireworks: [Firework] = []
    @Published var particles: [FireworkParticle] = []
    @Published var flashes: [Flash] = []
    
    var screenSize: CGSize = .zero
    private var timer: Timer?
    private var launchTimer: Timer?
    private var isActive = false
    private var fireworkCount = 0
    private let maxFireworks = 8 // 最大同时存在的烟火数量
    
    func startFireworks() {
        guard screenSize.width > 0, screenSize.height > 0 else { return }
        
        isActive = true
        fireworkCount = 0
        
        print("🎆 开始烟火效果，屏幕尺寸: \(screenSize)")
        
        // 清除现有效果
        fireworks.removeAll()
        particles.removeAll()
        flashes.removeAll()
        
        // 立即发射第一波烟火
        launchFireworksWave()
        
        // 开始发射烟火
        launchTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            self?.launchFireworksWave()
        }
        
        // 更新物理模拟
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.updatePhysics()
        }
        
        // 8秒后停止
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
            self?.stopFireworks()
        }
    }
    
    private func launchFireworksWave() {
        guard isActive, fireworkCount < maxFireworks else { return }
        
        // 同时发射2-4个烟火
        let count = Int.random(in: 2...4)
        for _ in 0..<count {
            if fireworkCount < maxFireworks {
                launchFirework()
                fireworkCount += 1
            }
        }
    }
    
    private func launchFirework() {
        guard isActive, screenSize.height > 0 else { return }
        
        // 直接从屏幕中上部随机位置爆炸（跳过发射过程）
        // 这样可以避免底部边界问题
        let explosionX = CGFloat.random(in: 100...(screenSize.width - 100))
        let explosionY = CGFloat.random(in: 100...(screenSize.height * 0.6))  // 屏幕上半部分
        
        // 随机选择颜色
        let colorIndex = Int.random(in: 0...2)
        let mainColor: Color
        switch colorIndex {
        case 0:
            mainColor = Color(red: 1.0, green: 0.2, blue: 0.2)  // 红色
        case 1:
            mainColor = Color(red: 0.2, green: 0.6, blue: 1.0)  // 蓝色
        default:
            mainColor = .white
        }
        
        // 直接创建爆炸
        let firework = Firework(
            position: CGPoint(x: explosionX, y: explosionY),
            velocity: CGPoint.zero,
            color: mainColor,
            size: 12
        )
        firework.state = .exploding  // 直接设置为爆炸状态
        
        fireworks.append(firework)
        
        // 立即触发爆炸效果
        if let index = fireworks.firstIndex(where: { $0.id == firework.id }) {
            explodeFirework(at: index)
        }
    }
    
    private func explodeFirework(at index: Int) {
        guard index < fireworks.count else { return }
        
        let firework = fireworks[index]
        print("🎆 爆炸烟火: 位置=\(firework.position)")
        firework.state = .exploding
        
        // 创建爆炸闪光
        let flash = Flash(position: firework.position, color: firework.mainColor)
        flashes.append(flash)
        
        // 创建爆炸粒子
        let particleCount = Int.random(in: 80...150)
        for _ in 0..<particleCount {
            // 随机选择粒子颜色：红、蓝、白
            let colorIndex = Int.random(in: 0...2)
            let particleColor: Color
            switch colorIndex {
            case 0:
                particleColor = Color(red: 1.0, green: 0.3, blue: 0.3)  // 红色
            case 1:
                particleColor = Color(red: 0.3, green: 0.7, blue: 1.0)  // 蓝色
            default:
                particleColor = .white
            }
            
            // 随机粒子速度（向各个方向扩散，覆盖整个屏幕）
            let angle = Double.random(in: 0..<360) * Double.pi / 180
            let speed = CGFloat.random(in: 15...40) / 10.0
            let velocity = CGPoint(
                x: CGFloat(cos(angle)) * speed,
                y: CGFloat(sin(angle)) * speed
            )
            
            let particle = FireworkParticle(
                position: firework.position,
                velocity: velocity,
                color: particleColor,
                size: CGFloat.random(in: 4...10)
            )
            
            particles.append(particle)
        }
        
        // 播放爆炸音效（这里可以添加触觉反馈）
        HapticManager.shared.playClick(velocity: 1.0)
        
        // 2秒后开始下落
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self, index < self.fireworks.count else { return }
            self.fireworks[index].state = .falling
            self.fireworks[index].velocity = CGPoint(x: 0, y: 10)  // 下落速度
        }
        
        // 5秒后结束
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self, index < self.fireworks.count else { return }
            self.fireworks[index].state = .finished
            self.fireworks[index].opacity = 0
            self.fireworkCount -= 1
            print("🎆 烟火结束: index=\(index)")
        }
    }
    
    private func updatePhysics() {
        guard isActive else { return }
        
        // 更新烟火
        for i in fireworks.indices {
            fireworks[i].lifeTime += 1.0/60.0
            
            if fireworks[i].state == .launching || fireworks[i].state == .falling {
                // 应用重力 - 仅在falling状态下应用更多重力
                if fireworks[i].state == .falling {
                    fireworks[i].velocity.y += 0.5
                }
                
                // 更新位置
                fireworks[i].position.x += fireworks[i].velocity.x
                fireworks[i].position.y += fireworks[i].velocity.y
                
                // 边界检查 - 只有当烟火完全离开屏幕底部时才移除
                if fireworks[i].position.y > screenSize.height + 200 {
                    fireworks[i].state = .finished
                    fireworkCount -= 1
                }
            }
            
            // 生命周期结束
            if fireworks[i].lifeTime > fireworks[i].maxLifeTime {
                fireworks[i].opacity = max(0, fireworks[i].opacity - 0.02)
            }
        }
        
        // 更新粒子
        for i in particles.indices {
            particles[i].lifeTime += 1.0/60.0
            
            // 应用重力和空气阻力
            particles[i].velocity.y += 0.2
            particles[i].velocity.x *= 0.98
            particles[i].velocity.y *= 0.98
            
            // 更新位置
            particles[i].position.x += particles[i].velocity.x
            particles[i].position.y += particles[i].velocity.y
            
            // 淡出效果
            if particles[i].lifeTime > particles[i].maxLifeTime * 0.5 {
                particles[i].opacity = max(0, particles[i].opacity - 0.015)
            }
            
            // 生命周期结束
            if particles[i].lifeTime > particles[i].maxLifeTime {
                particles[i].opacity = 0
            }
        }
        
        // 更新闪光
        for i in flashes.indices {
            flashes[i].lifeTime += 1.0/60.0
            
            // 快速膨胀然后淡出
            if flashes[i].lifeTime < 0.2 {
                flashes[i].size += 150
            }
            
            // 淡出效果
            if flashes[i].lifeTime > 0.2 {
                flashes[i].opacity = max(0, flashes[i].opacity - 0.08)
            }
            
            // 生命周期结束
            if flashes[i].lifeTime > flashes[i].maxLifeTime {
                flashes[i].opacity = 0
            }
        }
        
        // 清理结束的粒子
        particles.removeAll { $0.opacity <= 0 }
        flashes.removeAll { $0.opacity <= 0 }
        fireworks.removeAll { $0.state == .finished && $0.opacity <= 0 }
    }
    
    func stopFireworks() {
        print("🎆 停止烟火效果")
        isActive = false
        launchTimer?.invalidate()
        launchTimer = nil
        timer?.invalidate()
        timer = nil
        
        // 淡出所有效果
        withAnimation(.easeOut(duration: 1.0)) {
            for i in fireworks.indices {
                fireworks[i].opacity = 0
            }
            for i in particles.indices {
                particles[i].opacity = 0
            }
            for i in flashes.indices {
                flashes[i].opacity = 0
            }
        }
        
        // 2秒后清除所有
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.fireworks.removeAll()
            self?.particles.removeAll()
            self?.flashes.removeAll()
        }
    }
    
    deinit {
        stopFireworks()
    }
}

// 烟火视图
struct FireworkView: View {
    let firework: Firework
    
    var body: some View {
        if firework.state == .launching {
            // 发射中的烟火
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            firework.mainColor,
                            .white,
                            firework.mainColor.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: firework.size, height: firework.size)
                .position(firework.position)
                .shadow(color: firework.mainColor.opacity(0.8), radius: 15, x: 0, y: 0)
                .blur(radius: 2)
        } else {
            // 爆炸或下落中的烟火
            EmptyView()
        }
    }
}

// 烟火粒子视图
struct FireworkParticleView: View {
    let particle: FireworkParticle
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        particle.color,
                        particle.color.opacity(0.7),
                        particle.color.opacity(0.3)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size)
            .position(particle.position)
            .shadow(color: particle.color.opacity(0.6), radius: 8, x: 0, y: 0)
            .blur(radius: particle.blur)
    }
}

// 爆炸闪光视图
struct FlashView: View {
    let flash: Flash
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.9),
                        flash.color.opacity(0.6),
                        .clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: flash.size / 2
                )
            )
            .frame(width: flash.size, height: flash.size)
            .position(flash.position)
            .blur(radius: 10)
            .opacity(flash.opacity)
    }
}

// 主烟火视图
struct FireworksView: View {
    @StateObject private var viewModel = FireworksViewModel()
    
    var body: some View {
        // 使用透明的全屏视图作为基础
        Color.clear
            .overlay(
                GeometryReader { geometry in
                    ZStack {
                        // 烟火背景光晕
                        if viewModel.fireworks.count > 0 {
                            ForEach(Array(viewModel.fireworks.enumerated()), id: \.element.id) { index, firework in
                                if firework.state == .exploding || firework.state == .falling {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                gradient: Gradient(colors: [
                                                    firework.mainColor.opacity(0.3),
                                                    firework.mainColor.opacity(0.1),
                                                    .clear
                                                ]),
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 80
                                            )
                                        )
                                        .frame(width: 160, height: 160)
                                        .position(firework.position)
                                        .blur(radius: 15)
                                        .opacity(firework.opacity * 0.5)
                                }
                            }
                        }
                        
                        // 烟火主体
                        ForEach(viewModel.fireworks) { firework in
                            FireworkView(firework: firework)
                        }
                        
                        // 爆炸粒子
                        ForEach(viewModel.particles) { particle in
                            FireworkParticleView(particle: particle)
                        }
                        
                        // 爆炸闪光
                        ForEach(viewModel.flashes) { flash in
                            FlashView(flash: flash)
                        }
                        
                        // 调试信息
                        VStack {
                            Text("🎆 烟火调试信息")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(5)
                            
                            Text("烟火数量: \(viewModel.fireworks.count)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(2)
                            
                            Text("粒子数量: \(viewModel.particles.count)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(2)
                        }
                        .position(x: geometry.size.width/2, y: 40)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .allowsHitTesting(false)
                    .onAppear {
                        print("🎆 FireworksView 出现，尺寸: \(geometry.size)")
                        viewModel.screenSize = geometry.size
                        viewModel.startFireworks()
                    }
                    .onChange(of: geometry.size) { newSize in
                        print("🎆 屏幕尺寸变化: \(newSize)")
                        viewModel.screenSize = newSize
                    }
                }
            )
            .ignoresSafeArea()  // 确保覆盖整个屏幕
            .onDisappear {
                viewModel.stopFireworks()
            }
    }
}
