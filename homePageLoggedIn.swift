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
        TabView(selection: $tableSelection) {
            LocationPage()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Locations")
                }
                .tag(1)
            
            PreferencePage()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Preferences")
                }
                .tag(2)
            
            SettingPage()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .overlay(alignment: .bottom) {
            CustomTabView(tableSelection: $tableSelection)
        }
    }
}

#Preview {
    homePageLoggedIn()
}
