// Core/EffectManager.swift
import SwiftUI
import Combine

class EffectManager: ObservableObject {
    static let shared = EffectManager()
    
    @Published var currentEffectMode: String = "fireworks" // "fireworks" 或 "crack"
    @Published var showSettingsInfo: Bool = false
    
    private let defaults = UserDefaults.standard
    
    private init() {
        // 从UserDefaults加载设置
        if let savedMode = defaults.string(forKey: "effect_mode") {
            currentEffectMode = savedMode
        } else {
            // 默认值为烟火效果
            currentEffectMode = "fireworks"
            defaults.set("fireworks", forKey: "effect_mode")
        }
        
        print("🎆 EffectManager 初始化，当前模式: \(currentEffectMode)")
    }
    
    // 注意：这个方法需要在调用时传入屏幕尺寸
    // 我们将修改调用方式，在ContentView中获取屏幕尺寸后调用
    func triggerEffect(screenSize: CGSize? = nil) {
        print("🎆 触发效果，当前模式: \(currentEffectMode)")
        
        switch currentEffectMode {
        case "crack":
            print("💥 触发玻璃破裂效果")
            
            // 如果有传入屏幕尺寸，使用它
            if let size = screenSize {
                print("💥 使用传入的屏幕尺寸: \(size)")
                CrackManager.shared.triggerCrack(screenSize: size)
            } else {
                // 如果没有传入，使用默认的 iPhone 16 Pro Max 尺寸
                let defaultSize = CGSize(width: 430, height: 932) // iPhone 16 Pro Max
                print("💥 使用默认屏幕尺寸: \(defaultSize)")
                CrackManager.shared.triggerCrack(screenSize: defaultSize)
            }
            
        case "fireworks":
            print("🎇 触发烟火效果")
            FireworksManager.shared.triggerFireworks()
        default:
            print("🎇 触发烟火效果 (默认)")
            FireworksManager.shared.triggerFireworks()
        }
    }
    
    func setEffectMode(_ mode: String) {
        guard mode == "fireworks" || mode == "crack" else { return }
        
        currentEffectMode = mode
        defaults.set(mode, forKey: "effect_mode")
        
        print("🎆 效果模式已更改为: \(mode)")
        
        // 显示切换提示
        showSettingsInfo = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showSettingsInfo = false
        }
    }
    
    func toggleEffectMode() {
        let newMode = currentEffectMode == "fireworks" ? "crack" : "fireworks"
        setEffectMode(newMode)
    }
    
    var currentEffectName: String {
        switch currentEffectMode {
        case "crack":
            return "Glass Crack"
        case "fireworks":
            return "Fireworks"
        default:
            return "Fireworks"
        }
    }
    
    var currentEffectDescription: String {
        switch currentEffectMode {
        case "crack":
            return "Trigger full-screen glass crack effect when reaching 100 times"
        case "fireworks":
            return "Trigger fireworks effect when reaching 100 times"
        default:
            return "Trigger fireworks effect when reaching 100 times"
        }
    }
    
    var currentEffectIcon: String {
        switch currentEffectMode {
        case "crack":
            return "burst"
        case "fireworks":
            return "sparkles"
        default:
            return "sparkles"
        }
    }
}
