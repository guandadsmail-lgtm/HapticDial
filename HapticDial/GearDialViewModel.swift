// ViewModels/GearDialViewModel.swift
import SwiftUI
import Combine

class GearDialViewModel: ObservableObject {
    @Published var spinCount: Int = 0
    @Published var isSpinning = false
    @Published var rotationAngle: Double = 0.0
    
    private var lastEffectCount = 0
    
    init() {}
    
    func spinGear() {
        guard !isSpinning else { return }
        
        isSpinning = true
        spinCount += 1
        
        // 检查是否需要触发特殊效果
        checkForEffect()
        
        HapticManager.shared.playClick()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            rotationAngle += 360
        }
        
        // 添加多个触觉反馈，模拟齿轮转动
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            HapticManager.shared.playClick(velocity: 0.6)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            HapticManager.shared.playClick(velocity: 0.5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            HapticManager.shared.playClick(velocity: 0.4)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.isSpinning = false
        }
    }
    
    func resetCount() {
        spinCount = 0
        rotationAngle = 0
        lastEffectCount = 0
    }
    
    private func checkForEffect() {
        // 每当达到100或100的整数倍时触发效果
        if spinCount >= 100 && spinCount % 100 == 0 && spinCount > lastEffectCount {
            lastEffectCount = spinCount
            
            // 使用全局效果管理器来触发效果
            EffectManager.shared.triggerEffect()
        }
    }
}
