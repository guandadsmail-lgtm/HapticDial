// HapticDial/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DialViewModel()
    @StateObject private var bubbleViewModel = BubbleDialViewModel()
    @StateObject private var gearViewModel = GearDialViewModel()
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
                
                if isLandscape {
                    // 横屏布局：主转盘在中间，小转盘在两侧
                    HStack(spacing: 20) {
                        // 左侧：气泡转盘
                        VStack {
                            BubbleDialViewWrapper(viewModel: bubbleViewModel)
                                .padding(.bottom, 8)
                            
                            Text("BUBBLE")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(1)
                        }
                        
                        Spacer()
                        
                        // 主转盘区域
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
                            .padding(.bottom, 25)
                            
                            // 主转盘
                            DialViewRedesigned(viewModel: viewModel)
                                .padding(.vertical, 10)
                            
                            Spacer(minLength: 10)
                            
                            // 模式描述
                            Text(viewModel.currentMode == .ratchet ? "Mechanical click every 12°" : "Smooth detent every 22.5°")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 20)
                            
                            Spacer(minLength: 15)
                            
                            // 模式选择器
                            ModeSelector(selectedMode: $viewModel.currentMode)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 30)
                        }
                        
                        Spacer()
                        
                        // 右侧：齿轮转盘
                        VStack {
                            GearDialViewWrapper(viewModel: gearViewModel)
                                .padding(.bottom, 8)
                            
                            Text("GEAR")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(1)
                        }
                    }
                    .padding(.horizontal, 30)
                } else {
                    // 竖屏布局：主转盘在上方，小转盘在下方
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
                        .padding(.bottom, 40)
                        
                        // 主转盘
                        DialViewRedesigned(viewModel: viewModel)
                            .padding(.vertical, 10)
                        
                        Spacer(minLength: 20)
                        
                        // 模式描述
                        Text(viewModel.currentMode == .ratchet ? "Mechanical click every 12°" : "Smooth detent every 22.5°")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 60)
                        
                        Spacer()
                        
                        // 小转盘区域
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                BubbleDialViewWrapper(viewModel: bubbleViewModel)
                                Text("BUBBLE")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                    .tracking(1)
                            }
                            
                            VStack(spacing: 8) {
                                GearDialViewWrapper(viewModel: gearViewModel)
                                Text("GEAR")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                    .tracking(1)
                            }
                        }
                        .padding(.bottom, 40)
                        
                        // 模式选择器
                        ModeSelector(selectedMode: $viewModel.currentMode)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                    }
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
            SettingsView(
                viewModel: viewModel,
                bubbleViewModel: bubbleViewModel,
                gearViewModel: gearViewModel
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// 包装器视图，用于传递ViewModel
struct BubbleDialViewWrapper: View {
    @ObservedObject var viewModel: BubbleDialViewModel
    
    var body: some View {
        ZStack {
            BubbleDialView(viewModel: viewModel)
        }
    }
}

struct GearDialViewWrapper: View {
    @ObservedObject var viewModel: GearDialViewModel
    
    var body: some View {
        ZStack {
            GearDialView(viewModel: viewModel)
        }
    }
}
