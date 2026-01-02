// Views/SettingsView.swift
import SwiftUI
import Combine

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DialViewModel
    @ObservedObject var bubbleViewModel: BubbleDialViewModel
    @ObservedObject var gearViewModel: GearDialViewModel
    @ObservedObject private var hapticManager = HapticManager.shared
    @ObservedObject private var effectManager = EffectManager.shared
    
    // 颜色定义
    private let orangePinkColor = Color(red: 1.0, green: 0.4, blue: 0.3)
    private let bubbleColor = Color(red: 0.2, green: 0.8, blue: 1.0)
    private let gearColor = Color(red: 1.0, green: 0.4, blue: 0.2)
    private let fireworksColor = Color(red: 1.0, green: 0.6, blue: 0.2)
    private let crackColor = Color(red: 0.2, green: 0.8, blue: 1.0)
    
    var body: some View {
        NavigationView {
            List {
                // 特殊效果设置
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SPECIAL EFFECT")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1)
                            .padding(.bottom, 4)
                        
                        // 效果模式选择器
                        HStack(spacing: 12) {
                            // 烟火效果选项
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    effectManager.setEffectMode("fireworks")
                                }
                                hapticManager.playClick()
                            }) {
                                VStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(effectManager.currentEffectMode == "fireworks" ?
                                                  fireworksColor.opacity(0.15) :
                                                  Color.white.opacity(0.05))
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 24))
                                            .foregroundColor(effectManager.currentEffectMode == "fireworks" ?
                                                           fireworksColor :
                                                           .white.opacity(0.5))
                                    }
                                    
                                    Text("Fireworks")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(effectManager.currentEffectMode == "fireworks" ?
                                                       fireworksColor :
                                                       .white.opacity(0.6))
                                    
                                    if effectManager.currentEffectMode == "fireworks" {
                                        Circle()
                                            .fill(fireworksColor)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 2)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                            
                            // 玻璃破裂效果选项
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    effectManager.setEffectMode("crack")
                                }
                                hapticManager.playClick()
                            }) {
                                VStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(effectManager.currentEffectMode == "crack" ?
                                                  crackColor.opacity(0.15) :
                                                  Color.white.opacity(0.05))
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "burst")
                                            .font(.system(size: 24))
                                            .foregroundColor(effectManager.currentEffectMode == "crack" ?
                                                           crackColor :
                                                           .white.opacity(0.5))
                                    }
                                    
                                    Text("Glass Crack")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(effectManager.currentEffectMode == "crack" ?
                                                       crackColor :
                                                       .white.opacity(0.6))
                                    
                                    if effectManager.currentEffectMode == "crack" {
                                        Circle()
                                            .fill(crackColor)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 2)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 8)
                        
                        // 当前模式描述
                        Text(effectManager.currentEffectDescription)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 8)
                        
                        // 测试按钮
                        Button(action: {
                            print("🎯 测试效果，当前模式: \(effectManager.currentEffectMode)")
                            effectManager.triggerEffect()
                            hapticManager.playClick()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14))
                                Text("Test Effect")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(effectManager.currentEffectMode == "fireworks" ?
                                           fireworksColor :
                                           crackColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill((effectManager.currentEffectMode == "fireworks" ?
                                           fireworksColor :
                                           crackColor).opacity(0.1))
                            )
                        }
                        .padding(.top, 12)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Special Effects")
                } footer: {
                    Text("Choose what happens when you reach 100 taps or 100 rotations")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
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
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1001")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
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
