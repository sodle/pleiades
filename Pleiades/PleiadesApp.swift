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
    @Published var deviceRegistered = false
    @Published var account: Account?
    @Published var vehicles: [VehicleStub]?
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
        
        loadCookie()
        
        guard let vehicles = try? await refreshVehicles() else {
            appState.loading = false
            appState.failed = true
            return
        }
        
        appState.loading = false
        appState.loggedIn = vehicles.success
        appState.deviceRegistered = vehicles.data.deviceRegistered
        appState.account = vehicles.data.account
        appState.vehicles = vehicles.data.vehicles
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
