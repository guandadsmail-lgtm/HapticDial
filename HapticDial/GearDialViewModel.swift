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
        
        // Check if special effect should be triggered
        checkForEffect()
        
        HapticManager.shared.playClick()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            rotationAngle += 360
        }
        
        // Add multiple haptic feedback to simulate gear rotation
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
        // Trigger effect when reaching 100 or multiples of 100
        if spinCount >= 100 && spinCount % 100 == 0 && spinCount > lastEffectCount {
            lastEffectCount = spinCount
            
            // Use global effect manager to trigger effect
            EffectManager.shared.triggerEffect()
        }
    }
}
