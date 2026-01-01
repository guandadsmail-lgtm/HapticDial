// Views/SettingsView.swift
import SwiftUI
import Combine

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DialViewModel
    @ObservedObject var bubbleViewModel: BubbleDialViewModel
    @ObservedObject var gearViewModel: GearDialViewModel
    @ObservedObject private var hapticManager = HapticManager.shared
    
    // 颜色定义
    private let orangePinkColor = Color(red: 1.0, green: 0.4, blue: 0.3)
    private let bubbleColor = Color(red: 0.2, green: 0.8, blue: 1.0)
    private let gearColor = Color(red: 1.0, green: 0.4, blue: 0.2)
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Haptic Feedback", isOn: $viewModel.hapticEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: orangePinkColor))
                    
                    if viewModel.hapticEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "hand.tap")
                                    .foregroundColor(orangePinkColor.opacity(0.8))
                                    .frame(width: 24)
                                
                                Text("Haptic Intensity")
                                    .font(.system(size: 15))
                                
                                Spacer()
                                
                                Text("\(Int(hapticManager.hapticIntensity * 100))%")
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                            
                            Slider(value: Binding(
                                get: { hapticManager.hapticIntensity },
                                set: { hapticManager.setHapticIntensity($0) }
                            ), in: 0.1...1.0, step: 0.1) {
                                Text("Haptic Intensity")
                            }
                            .accentColor(orangePinkColor)
                            
                            HStack(spacing: 20) {
                                Button("Test") {
                                    hapticManager.testHaptic()
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(orangePinkColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(orangePinkColor.opacity(0.1))
                                )
                                
                                Spacer()
                                
                                // 强度预览标签
                                HStack(spacing: 8) {
                                    ForEach(1...5, id: \.self) { level in
                                        Circle()
                                            .fill(orangePinkColor.opacity(
                                                hapticManager.hapticIntensity >= Float(level) / 5 ?
                                                0.6 : 0.2
                                            ))
                                            .frame(width: 6, height: 6)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    Toggle("Sound", isOn: $viewModel.soundEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: bubbleColor))
                } header: {
                    Text("Feedback Settings")
                } footer: {
                    Text("Adjust the strength of haptic feedback. Sound uses system sound which doesn't support volume control.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack {
                        Text("Main Dial Rotation")
                        Spacer()
                        Text("\(Int(viewModel.totalRotation / 360)) rotations")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Bubble Taps")
                        Spacer()
                        Text("\(bubbleViewModel.tapCount)")
                            .foregroundColor(bubbleColor)
                    }
                    
                    HStack {
                        Text("Gear Spins")
                        Spacer()
                        Text("\(gearViewModel.spinCount)")
                            .foregroundColor(gearColor)
                    }
                    
                    Button("Reset All Statistics") {
                        viewModel.resetStats()
                        bubbleViewModel.resetCount()
                        gearViewModel.resetCount()
                    }
                    .foregroundColor(orangePinkColor)
                } header: {
                    Text("Statistics")
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(orangePinkColor)
                }
            }
        }
        .accentColor(orangePinkColor)
    }
}
