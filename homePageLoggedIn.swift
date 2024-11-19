//
//  homePageLoggedIn.swift
//  MiamiMarketStore
//
//  Created by Alessandro Escobar on 11/8/24.
// Edited by Alejandro Alonso on 11/19/24

import SwiftUI

struct homePageLoggedIn: View {
    @State private var tableSelection = 1
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                TabView(selection: $tableSelection) {
                    LocationPage()
                        .tabItem {
                            Image(systemName: "map.fill")
                                .renderingMode(.template)
                                .foregroundColor(.blue)
                            Text("Locations")
                        }
                        .tag(1)
                    
                    PreferencePage()
                        .tabItem {
                            Image(systemName: "list.bullet.clipboard.fill")
                                .renderingMode(.template)
                                .foregroundColor(.green)
                            Text("Preferences")
                        }
                        .tag(2)
                    
                    SettingPage()
                        .tabItem {
                            Image(systemName: "gear")
                                .renderingMode(.template)
                                .foregroundColor(.red)
                            Text("Settings")
                        }
                        .tag(3)
                }
                .accentColor(.blue)
                .padding(.top, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.8))
                        .shadow(radius: 5)
                        .edgesIgnoringSafeArea(.bottom)
                )
            }
            .overlay(alignment: .bottom) {
                CustomTabView(tableSelection: $tableSelection)
                    .background(
                        BlurView(style: .systemMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .shadow(radius: 10)
                    )
                    .padding()
                    .animation(.easeInOut(duration: 0.3), value: tableSelection)
            }
        }
    }
}

// Add a blur view for iOS style
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

#Preview {
    homePageLoggedIn()
}
