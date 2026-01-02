// ViewModels/BubbleDialViewModel.swift
import SwiftUI
import Combine

class BubbleDialViewModel: ObservableObject {
    @Published var tapCount: Int = 0
    @Published var bubbleOpacity: Double = 1.0
    
    private var lastEffectCount = 0
    
    func incrementCount() {
        tapCount += 1
        bubbleOpacity = 0.8
        
        // 检查是否需要触发特殊效果
        checkForEffect()
        
        HapticManager.shared.playClick()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.bubbleOpacity = 1.0
            }
        }
    }
    
    func resetCount() {
        tapCount = 0
        lastEffectCount = 0
    }
    
    private func checkForEffect() {
        // 每当达到100或100的整数倍时触发效果
        if tapCount >= 100 && tapCount % 100 == 0 && tapCount > lastEffectCount {
            lastEffectCount = tapCount
            
            // 使用全局效果管理器来触发效果
            EffectManager.shared.triggerEffect()
        }
    }
}
