// Views/SettingsView.swift
import SwiftUI
import CoreGraphics

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DialViewModel
    @ObservedObject private var hapticManager = HapticManager.shared
    @State private var hapticIntensity: Float = 0.7
    
    // 橙粉色
    private let orangePinkColor = Color(red: 1.0, green: 0.4, blue: 0.3)
    
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
                        Text("Rotation Count")
                        Spacer()
                        Text("\(Int(viewModel.totalRotation / 360)) rotations")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Reset Statistics") {
                        viewModel.resetStats()
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
