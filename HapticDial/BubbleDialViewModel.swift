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
        // When reaching 100 or multiples of 100, trigger the effect
        if tapCount >= 100 && tapCount % 100 == 0 && tapCount > lastEffectCount {
            lastEffectCount = tapCount
            EffectManager.shared.triggerEffect()
        }
    }
}
