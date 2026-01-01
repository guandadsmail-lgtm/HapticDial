// HapticDial/HapticDialApp.swift
import SwiftUI

@main
struct HapticDialApp: App {
    @State private var isLaunching = true
    
    var body: some Scene {
        WindowGroup {
            if isLaunching {
                LaunchScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation {
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

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color(red: 0.03, green: 0.03, blue: 0.08)
                .ignoresSafeArea()
            
            VStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(360))
                    .animation(
                        Animation.linear(duration: 2)
                            .repeatForever(autoreverses: false),
                        value: true
                    )
                
                Text("ARC")
                    .font(.system(size: 32, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
        }
    }
}
