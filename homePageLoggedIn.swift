//
//  homePageLoggedIn.swift
//  MiamiMarketStore
//
//  Created by Alessandro Escobar on 11/8/24.
//

import SwiftUI

struct homePageLoggedIn: View {
    @State private var tableSelection = 1
    var body: some View {
        TabView(selection: $tableSelection){
            LocationPage()
                .tabItem{
                    
                        
            }
            PreferencePage()
                .tabItem{
                        
            }
            SettingPage()
                .tabItem{
                        
            }
    }
        .overlay(alignment: .bottom){
            //custonTabView
            CustomTabView(tableSelection: $tableSelection)
            
        }
            
            
        
        
    }
}

#Preview {
    homePageLoggedIn()
}
