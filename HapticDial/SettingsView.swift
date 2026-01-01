// Views/SettingsView.swift
import SwiftUI
import Combine  // 添加这行

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DialViewModel
    @ObservedObject var bubbleViewModel: BubbleDialViewModel
    @ObservedObject var gearViewModel: GearDialViewModel
    @ObservedObject private var hapticManager = HapticManager.shared
    @State private var hapticIntensity: Float = 0.7
    
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
                    
                    Toggle("Sound", isOn: $viewModel.soundEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: orangePinkColor))
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
