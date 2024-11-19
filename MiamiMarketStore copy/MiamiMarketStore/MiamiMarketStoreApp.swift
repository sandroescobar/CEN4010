//
//  MiamiMarketStoreApp.swift
//  MiamiMarketStore
//
//  Created by Alessandro Escobar on 8/28/24.
//

import SwiftUI
import Firebase



class AppDelegate: NSObject, UIApplicationDelegate {
    // Configure Firebase when the app finishes launching
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MiamiMarketStoreApp: App {
    // Register the AppDelegate to be used in the app
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
    
    
}





