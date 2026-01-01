// HapticDial/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DialViewModel()
    @State private var showSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let verticalPadding: CGFloat = isLandscape ? 20 : 40
            
            ZStack {
                // 深度渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.03, green: 0.03, blue: 0.08),
                        Color(red: 0.08, green: 0.05, blue: 0.15),
                        Color(red: 0.05, green: 0.05, blue: 0.12)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 标题
                    Text("HAPTIC DIAL")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(2)
                        .padding(.top, verticalPadding)
                    
                    Spacer()
                    
                    // 模式名称和图标
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.currentMode == .ratchet ? "gear" : "camera.aperture")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(viewModel.currentMode.displayName)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, isLandscape ? 25 : 40)
                    
                    // 使用重新设计的转盘
                    DialViewRedesigned(viewModel: viewModel)
                        .padding(.vertical, 10)
                    
                    Spacer(minLength: isLandscape ? 10 : 20)
                    
                    // 模式描述 - 大幅增加与转盘的间距
                    Text(viewModel.currentMode == .ratchet ? "Mechanical click every 12°" : "Smooth detent every 22.5°")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, isLandscape ? 20 : 60)  // 横屏时减少间距，竖屏时大幅增加
                    
                    Spacer(minLength: isLandscape ? 5 : 15)
                    
                    // 模式选择器
                    ModeSelector(selectedMode: $viewModel.currentMode)
                        .padding(.horizontal, 40)
                        .padding(.bottom, isLandscape ? 20 : 40)
                }
                
                // 设置按钮
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showSettings.toggle() }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 44, height: 44)
                                .background(
                                    .ultraThinMaterial,
                                    in: Circle()
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.top, 12)
                        .padding(.trailing, 16)
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}
