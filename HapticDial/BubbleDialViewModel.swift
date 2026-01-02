// ViewModels/BubbleDialViewModel.swift
import SwiftUI
import Combine

class BubbleDialViewModel: ObservableObject {
    @Published var tapCount: Int = 0
    @Published var bubbleOpacity: Double = 1.0
    
    private var lastFireworksCount = 0
    
    func incrementCount() {
        tapCount += 1
        bubbleOpacity = 0.8
        
        // 检查是否需要触发烟火效果
        checkForFireworks()
        
        HapticManager.shared.playClick()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.bubbleOpacity = 1.0
            }
        }
    }
    
    func resetCount() {
        tapCount = 0
        lastFireworksCount = 0
    }
    
    private func checkForFireworks() {
        // 每当达到100或100的整数倍时触发烟火
        if tapCount >= 100 && tapCount % 100 == 0 && tapCount > lastFireworksCount {
            lastFireworksCount = tapCount
            FireworksManager.shared.triggerFireworks()
        }
    }
}
