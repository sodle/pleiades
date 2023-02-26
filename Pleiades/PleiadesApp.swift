//
//  PleiadesApp.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var currentRegion = SB_CURRENT_REGION
    @Published var loggedIn = false
    @Published var loading = true
    @Published var failed = false
}

@main
struct PleiadesApp: App {
    @StateObject var appState = AppState()
    
    @MainActor
    func initializeApp() async {
        if appState.currentRegion == .NotSelected {
            appState.loading = false
            return
        }
        
        guard let session = try? await validateSession() else {
            appState.loading = false
            appState.failed = true
            return
        }
        
        appState.loading = false
        appState.loggedIn = session.success
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    await initializeApp()
                }
        }
    }
}
