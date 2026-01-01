// Core/HapticManager.swift
import CoreHaptics
import AVFoundation
import Combine
import AudioToolbox
import CoreGraphics

class HapticManager: NSObject, ObservableObject {
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticPatternPlayer?
    private var isEngineStarted = false
    
    @Published var currentMode: DialMode = .ratchet
    @Published var isEnabled = true
    @Published var volume: Float = 0.5  // 默认音量50%
    @Published var hapticIntensity: Float = 0.7  // 默认触感强度70%
    
    // 使用系统声音 ID
    private let ratchetSoundID: SystemSoundID = 1104  // 轻微点击声
    private let apertureSoundID: SystemSoundID = 1103  // 更柔和的点击声
    
    // 添加UserDefaults存储
    private let defaults = UserDefaults.standard
    private let volumeKey = "haptic_volume"
    private let intensityKey = "haptic_intensity"
    
    private override init() {
        super.init()
        
        // 从UserDefaults加载设置
        volume = defaults.float(forKey: volumeKey) == 0 ? 0.5 : defaults.float(forKey: volumeKey)
        hapticIntensity = defaults.float(forKey: intensityKey) == 0 ? 0.7 : defaults.float(forKey: intensityKey)
        
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("设备不支持高级触觉")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            
            // 设置引擎重置处理器
            engine?.resetHandler = { [weak self] in
                print("触觉引擎重置")
                self?.isEngineStarted = false
                self?.startEngine()
            }
            
            // 停止处理器
            engine?.stoppedHandler = { reason in
                print("触觉引擎停止: \(reason.rawValue)")
            }
            
            startEngine()
            
        } catch {
            print("创建触觉引擎失败: \(error.localizedDescription)")
        }
    }
    
    private func startEngine() {
        guard let engine = engine, !isEngineStarted else { return }
        
        do {
            try engine.start()
            isEngineStarted = true
            print("触觉引擎启动成功")
        } catch {
            print("启动触觉引擎失败: \(error)")
        }
    }
    
    func playClick(velocity: Double = 1.0) {
        guard isEnabled, let engine = engine, isEngineStarted else { return }
        
        // 根据模式选择参数
        let sharpness: Float
        let baseIntensity: Float
        
        switch currentMode {
        case .ratchet:
            sharpness = 0.9
            baseIntensity = 0.7
        case .aperture:
            sharpness = 0.3
            baseIntensity = 0.4
        }
        
        // 应用用户设置的强度
        let userIntensity = hapticIntensity
        let baseWithUser = baseIntensity * userIntensity
        
        // 根据速度调整强度
        let intensity = Float(min(1.0, Double(baseWithUser) * velocity))
        
        do {
            let clickEvent = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
                ],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [clickEvent], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            
            // 播放对应的声音（根据音量决定是否播放）
            if volume > 0 {
                playSound(for: currentMode)
            }
            
        } catch {
            print("播放触觉失败: \(error)")
        }
    }
    
    private func playSound(for mode: DialMode) {
        // iOS 系统声音不支持音量调节，只能控制是否播放
        let soundID = mode == .ratchet ? ratchetSoundID : apertureSoundID
        
        // 如果音量为0则不播放声音
        if volume > 0 {
            AudioServicesPlaySystemSound(soundID)
        }
    }
    
    // 添加设置保存方法
    func setVolume(_ value: Float) {
        volume = value
        defaults.set(value, forKey: volumeKey)
    }
    
    func setHapticIntensity(_ value: Float) {
        hapticIntensity = value
        defaults.set(value, forKey: intensityKey)
    }
    
    func startContinuousHaptic(intensity: Float = 0.5, sharpness: Float = 0.5) {
        guard let engine = engine, isEngineStarted else { return }
        
        do {
            let continuousEvent = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0,
                duration: 1.0
            )
            
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            continuousPlayer = try engine.makePlayer(with: pattern)
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
            
        } catch {
            print("创建持续触觉失败: \(error)")
        }
    }
    
    func updateContinuousHaptic(intensity: Float, sharpness: Float) {
        do {
            let dynamicParameter = CHHapticDynamicParameter(
                parameterID: .hapticIntensityControl,
                value: intensity,
                relativeTime: 0
            )
            try continuousPlayer?.sendParameters([dynamicParameter], atTime: 0)
        } catch {
            print("更新持续触觉失败: \(error)")
        }
    }
    
    func stopContinuousHaptic() {
        do {
            try continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        } catch {
            print("停止持续触觉失败: \(error)")
        }
    }
    
    // 提供测试方法
    func testHaptic() {
        playClick()
    }
}
