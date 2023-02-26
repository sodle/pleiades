//
//  ContentView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            if appState.loading {
                Text("Loading...")
            } else if appState.currentRegion == .NotSelected {
                RegionSelectView().task {
                    appState.failed = false
                }
            } else if appState.loggedIn {
                Text("Logged in!")
            } else if appState.failed {
                TopLevelErrorView()
            } else {
                LoginView()
            }
        }
        .padding()
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
            ContentView()
                .environmentObject({() -> AppState in
                    let state = AppState()
                    state.loading = false
                    state.currentRegion = .UnitedStates
                    state.loggedIn = true
                    return state
                }())
                .previewDisplayName("Logged in")
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
