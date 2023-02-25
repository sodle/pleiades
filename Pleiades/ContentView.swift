//
//  ContentView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var currentRegion = SB_CURRENT_REGION
    @Published var loggedIn = false
}

struct ContentView: View {
    @StateObject var appState = AppState()
    
    @State var loading = true
    @State var failed = false
    
    @MainActor
    func checkSession() async {
        if appState.currentRegion == .NotSelected {
            loading = false
            return
        }
        
        guard let session = try? await validateSession() else {
            self.loading = false
            self.failed = true
            return
        }
        
        self.loading = false
        appState.loggedIn = session.success
    }
    
    var body: some View {
        VStack {
            if loading {
                Text("Loading...")
            } else if appState.currentRegion == .NotSelected {
                RegionSelectView().task {
                    self.failed = false
                }
            } else if failed {
                TopLevelErrorView()
            } else if appState.loggedIn {
                Text("Logged in!")
            } else {
                LoginView()
            }
        }
        .environmentObject(appState)
        .padding()
        .task {
            await checkSession()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Log in with your Subaru account:")
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
            Button("Log In") {
                Task {
                    let result = try! await logIn(username: email, password: password, deviceId: UIDevice.current.identifierForVendor!.uuidString)
                    if result.success {
                        appState.loggedIn = true
                    }
                }
            }.buttonStyle(.borderedProminent)
            HStack {
                Text("Selected region:")
                Text(emojiForRegion(appState.currentRegion))
                Text(appState.currentRegion.rawValue)
                Button("Change...") {
                    appState.currentRegion = .NotSelected
                }
            }
        }
    }
}

struct RegionSelectView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Select your region:")
            ForEach(SBRegion.allCases.filter {$0 != .NotSelected}, id: \.rawValue) { region in
                Button("\(emojiForRegion(region))\t\(region.rawValue)") {
                    SB_CURRENT_REGION = region
                    appState.currentRegion = region
                }.buttonStyle(.bordered)
            }
        }
    }
}

struct TopLevelErrorView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Failed to initialize the app!")
            Text("Switching regions sometimes fixes this.")
            Button("Switch region...") {
                appState.currentRegion = .NotSelected
            }.buttonStyle(.borderedProminent)
        }
    }
}
