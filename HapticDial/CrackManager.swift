// Core/CrackManager.swift
import SwiftUI
import Combine

class CrackManager: ObservableObject {
    static let shared = CrackManager()
    
    @Published var showCracks = false
    @Published var cracks: [Crack] = []
    @Published var crackOpacity: Double = 1.0
    @Published var crackSoundEnabled = true
    
    private var timer: Timer?
    private let crackDuration: TimeInterval = 30.0
    private var startTime: Date?
    private var screenSize: CGSize = .zero
    
    private init() {
        // 从UserDefaults加载设置
        let defaults = UserDefaults.standard
        crackSoundEnabled = defaults.object(forKey: "crack_sound") as? Bool ?? true
    }
    
    func setScreenSize(_ size: CGSize) {
        self.screenSize = size
    }
    
    func triggerCrack(at position: CGPoint? = nil) {
        guard !showCracks, screenSize.width > 0, screenSize.height > 0 else { return }
        
        print("💥 触发玻璃破裂效果")
        
        showCracks = true
        crackOpacity = 1.0
        cracks.removeAll()
        
        // 记录开始时间
        startTime = Date()
        
        // 如果指定了位置，从该位置开始；否则从随机位置开始
        let crackPosition = position ?? randomPositionOnScreen()
        
        // 生成初始裂纹
        generateInitialCracks(from: crackPosition)
        
        // 播放破裂音效
        if crackSoundEnabled {
            playCrackSound()
        }
        
        // 播放强力触觉反馈
        playHeavyHaptic()
        
        // 开始扩展裂纹
        startCrackExpansion()
        
        // 30秒后停止效果
        DispatchQueue.main.asyncAfter(deadline: .now() + crackDuration) {
            self.stopCracks()
        }
    }
    
    private func randomPositionOnScreen() -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: screenSize.width * 0.2...(screenSize.width * 0.8)),
            y: CGFloat.random(in: screenSize.height * 0.2...(screenSize.height * 0.8))
        )
    }
    
    private func generateInitialCracks(from position: CGPoint) {
        // 生成4-6条主要裂纹
        let mainCrackCount = Int.random(in: 4...6)
        
        for i in 0..<mainCrackCount {
            let angle = Double(i) * (360.0 / Double(mainCrackCount)) + Double.random(in: -15...15)
            let length = CGFloat.random(in: min(screenSize.width, screenSize.height) * 0.15...min(screenSize.width, screenSize.height) * 0.25)
            
            let crack = Crack(
                id: UUID(),
                startPoint: position,
                endPoint: calculateEndpoint(from: position, angle: angle, length: length),
                thickness: CGFloat.random(in: 1.5...2.5),
                depth: 1, // 主要裂纹深度为1
                parentCrackId: nil,
                hasSubCracks: true,
                animationProgress: 0,
                growthSpeed: Double.random(in: 0.02...0.04)
            )
            
            cracks.append(crack)
        }
    }
    
    private func calculateEndpoint(from start: CGPoint, angle: Double, length: CGFloat) -> CGPoint {
        let radian = angle * Double.pi / 180
        return CGPoint(
            x: start.x + CGFloat(length * cos(radian)),
            y: start.y + CGFloat(length * sin(radian))
        )
    }
    
    private func playCrackSound() {
        // 播放系统破裂声音
        AudioServicesPlaySystemSound(1105) // 轻微破裂声
    }
    
    private func playHeavyHaptic() {
        // 播放强力的触觉反馈
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                let engine = try CHHapticEngine()
                try engine.start()
                
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0)
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: CHHapticTimeImmediate)
                
            } catch {
                print("触觉反馈播放失败: \(error)")
            }
        }
    }
    
    private func startCrackExpansion() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 扩展现有裂纹
            self.expandExistingCracks()
            
            // 生成新的分支裂纹
            self.generateBranchCracks()
            
            // 逐渐淡出（最后5秒开始）
            if let startTime = self.startTime {
                let elapsed = Date().timeIntervalSince(startTime)
                if elapsed > self.crackDuration - 5 {
                    self.crackOpacity = max(0, 1 - (elapsed - (self.crackDuration - 5)) / 5)
                }
            }
        }
    }
    
    private func expandExistingCracks() {
        for i in cracks.indices {
            // 如果裂纹还没完全扩展
            if cracks[i].animationProgress < 1.0 {
                cracks[i].animationProgress = min(1.0, cracks[i].animationProgress + cracks[i].growthSpeed)
            }
        }
    }
    
    private func generateBranchCracks() {
        // 从现有的主要裂纹生成分支
        var newCracks: [Crack] = []
        
        for crack in cracks where crack.depth < 3 && crack.animationProgress >= 0.7 && crack.hasSubCracks {
            // 有一定几率生成分支
            if Double.random(in: 0...1) < 0.25 {
                let branchCount = Int.random(in: 1...2)
                
                for _ in 0..<branchCount {
                    // 从裂纹的随机点生成分支
                    let randomProgress = CGFloat.random(in: 0.3...0.7)
                    let branchPoint = CGPoint(
                        x: crack.startPoint.x + (crack.endPoint.x - crack.startPoint.x) * randomProgress,
                        y: crack.startPoint.y + (crack.endPoint.y - crack.startPoint.y) * randomProgress
                    )
                    
                    // 计算主裂纹的角度
                    let mainAngle = atan2(
                        crack.endPoint.y - crack.startPoint.y,
                        crack.endPoint.x - crack.startPoint.x
                    ) * 180 / Double.pi
                    
                    // 分支角度在 ±30 到 ±60 度范围内
                    let branchAngle = mainAngle + Double.random(in: 30...60) * (Double.random(in: 0...1) > 0.5 ? 1 : -1)
                    let branchLength = CGFloat.random(in: 30...80) / CGFloat(crack.depth + 1)
                    
                    let branchCrack = Crack(
                        id: UUID(),
                        startPoint: branchPoint,
                        endPoint: calculateEndpoint(from: branchPoint, angle: branchAngle, length: branchLength),
                        thickness: crack.thickness * 0.6,
                        depth: crack.depth + 1,
                        parentCrackId: crack.id,
                        hasSubCracks: crack.depth < 2, // 只有前两层可以继续生成分支
                        animationProgress: 0,
                        growthSpeed: crack.growthSpeed * 0.8
                    )
                    
                    newCracks.append(branchCrack)
                }
                
                // 标记此裂纹已经生成了分支
                if let index = cracks.firstIndex(where: { $0.id == crack.id }) {
                    cracks[index].hasSubCracks = false
                }
            }
        }
        
        cracks.append(contentsOf: newCracks)
    }
    
    func stopCracks() {
        print("💥 停止玻璃破裂效果")
        
        timer?.invalidate()
        timer = nil
        
        withAnimation(.easeOut(duration: 1.0)) {
            crackOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showCracks = false
            self.cracks.removeAll()
        }
    }
    
    func toggleSound() {
        crackSoundEnabled.toggle()
        UserDefaults.standard.set(crackSoundEnabled, forKey: "crack_sound")
    }
    
    deinit {
        timer?.invalidate()
    }
}

// 裂纹数据模型
struct Crack: Identifiable {
    let id: UUID
    let startPoint: CGPoint
    let endPoint: CGPoint
    let thickness: CGFloat
    let depth: Int // 裂纹深度（层级）
    let parentCrackId: UUID? // 父裂纹ID，用于构建裂纹树
    var hasSubCracks: Bool // 是否还有未生成的分支
    var animationProgress: Double // 动画进度 0.0-1.0
    var growthSpeed: Double // 裂纹生长速度
}
