//
//  PleiadesApp.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import SwiftUI
import SubaruKit

class AppState: ObservableObject {
    @Published var currentRegion = SB_CURRENT_REGION
    @Published var loggedIn = false
    @Published var loading = true
    @Published var failed = false
    @Published var deviceRegistered = false
    @Published var account: Account?
    @Published var vehicles: [VehicleStub]?
}

var client: Client {
    Client(baseURL: SB_BASE_URL, deviceID: UIDevice.current.identifierForVendor!.uuidString)
}

@main
struct PleiadesApp: App {
    @StateObject var appState = AppState()
    
    @MainActor
    func initializeApp() async {
        if appState.currentRegion == .NotSelected {
            appState.loading = false
            appState.currentRegion = .UnitedStates
        }
        
        Task {
            if let restoredLogin = try? await client.tryRestoreSession(), restoredLogin {
                if let session = try? await client.validateSession(), session.success {
                    if let vehicles = try? await client.refreshVehicles(), vehicles.success, let data = vehicles.data {
                        appState.loading = false
                        appState.loggedIn = true
                        appState.deviceRegistered = data.deviceRegistered
                        appState.account = data.account
                        appState.vehicles = data.vehicles
                        return
                    }
                }
            }
            
            appState.loading = false
            appState.loggedIn = false
        }
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
