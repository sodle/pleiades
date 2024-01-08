//
//  ContentView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import SwiftUI
import SubaruKit

struct ContentView: View {
    var preview = false
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.loading {
            VStack {
                Text("Loading...")
            }
        } else if appState.currentRegion == .NotSelected {
            RegionSelectView().task {
                appState.failed = false
            }
        } else if appState.loggedIn {
            if appState.deviceRegistered {
                VehicleListView()
            } else {
                TwoFactorView(preview: preview)
            }
        } else if appState.failed {
            TopLevelErrorView()
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(AppState())
                .previewDisplayName("Loading")
            ContentView()
                .environmentObject({() -> AppState in
                    let state = AppState()
                    state.loading = false
                    return state
                }())
                .previewDisplayName("Region Select")
            ContentView(preview: true)
                .environmentObject({() -> AppState in
                    let state = AppState()
                    state.loading = false
                    state.currentRegion = .UnitedStates
                    state.loggedIn = true
                    return state
                }())
                .previewDisplayName("Two Factor")
            ContentView()
                .environmentObject({() -> AppState in
                    let state = AppState()
                    state.loading = false
                    state.currentRegion = .UnitedStates
                    state.loggedIn = true
                    state.deviceRegistered = true
                    state.account = Account(firstName: "John", lastName: "Smith")
                    state.vehicles = [
                        VehicleStub(vehicleName: "John's WRX", vin: "VXXX")
                    ]
                    return state
                }())
                .previewDisplayName("Logged In")
            ContentView()
                .environmentObject({() -> AppState in
                    let state = AppState()
                    state.loading = false
                    state.currentRegion = .UnitedStates
                    state.failed = true
                    return state
                }())
                .previewDisplayName("Failed")
            ContentView()
                .environmentObject({() -> AppState in
                    let state = AppState()
                    state.loading = false
                    state.currentRegion = .UnitedStates
                    return state
                }())
                .previewDisplayName("Login")
        }
    }
}
