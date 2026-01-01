// Views/ModeSelector.swift
import SwiftUI
import CoreGraphics

struct ModeSelector: View {
    @Binding var selectedMode: DialMode
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 25) {
            ForEach(DialMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = mode
                    }
                    HapticManager.shared.playClick()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: mode == .ratchet ? "gear" : "camera.aperture")
                            .font(.system(size: 20))
                            .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                        
                        Text(mode.displayName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                    }
                    .frame(width: 100, height: 70)
                    .background(
                        Group {
                            if selectedMode == mode {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.ultraThinMaterial)
                                    .matchedGeometryEffect(id: "background", in: animation)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                            } else {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.05))
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(
            Color.white.opacity(0.05)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
