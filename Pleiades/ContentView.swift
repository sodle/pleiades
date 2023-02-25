//
//  ContentView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var loggedIn = false
}

struct ContentView: View {
    @StateObject var appState = AppState()
    
    @State var loading = true
    @State var failed = false
    
    @MainActor
    func checkSession() async {
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
            } else if failed {
                Text("Failed to check session!")
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
            Text("Log in with your Subaru account")
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button("Log In") {
                Task {
                    let result = try! await logIn(username: email, password: password, deviceId: UIDevice.current.identifierForVendor!.uuidString)
                    if result.success {
                        appState.loggedIn = true
                    }
                }
            }
        }
    }
}
