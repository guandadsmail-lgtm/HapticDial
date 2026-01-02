// HapticDial/HapticDialApp.swift
import SwiftUI
import Combine

@main
struct HapticDialApp: App {
    @State private var isLaunching = true
    
    var body: some Scene {
        WindowGroup {
            if isLaunching {
                LaunchScreen()
                    .onAppear {
                        // 延长启动时间，确保动画完整播放
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                isLaunching = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
