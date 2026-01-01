// Core/HapticManager.swift
import CoreHaptics
import AVFoundation
import Combine  // 添加这个
import AudioToolbox  // 添加这个
import CoreGraphics

class HapticManager: NSObject, ObservableObject {  // 改为继承 NSObject
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticPatternPlayer?
    private var isEngineStarted = false
    
    // 触觉事件
    private var clickEvent: CHHapticEvent?
    private var softClickEvent: CHHapticEvent?
    
    @Published var currentMode: DialMode = .ratchet
    @Published var isEnabled = true
    @Published var volume: Float = 0.3  // 声音音量
    
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    
    private override init() {
        super.init()
        prepareHaptics()
        prepareAudio()
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
    
    private func prepareAudio() {
        // 初始化音频引擎
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        
        guard let audioEngine = audioEngine,
              let audioPlayerNode = audioPlayerNode else {
            print("音频引擎初始化失败")
            return
        }
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try audioEngine.start()
            audioPlayerNode.play()
            
            // 设置音频会话
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            print("音频引擎启动失败: \(error)")
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
        
        // 根据速度调整强度
        let intensity = Float(min(1.0, Double(baseIntensity) * velocity))
        
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
            
            // 播放对应的声音
            if volume > 0 {
                playSound(for: currentMode, velocity: velocity)
            }
            
        } catch {
            print("播放触觉失败: \(error)")
        }
    }
    
    private func playSound(for mode: DialMode, velocity: Double) {
        // 使用系统声音 - 使用不控制音量的版本
        let systemSound: SystemSoundID
        
        switch mode {
        case .ratchet:
            systemSound = 1104  // 轻微点击声
        case .aperture:
            systemSound = 1103  // 更柔和的点击声
        }
        
        // 使用标准的播放函数
        AudioServicesPlaySystemSound(systemSound)
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
}
