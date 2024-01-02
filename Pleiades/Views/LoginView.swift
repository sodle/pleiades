//
//  LoginView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/25/23.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    
    @State var alertActive = false
    @State var alertTitle = ""
    @State var alertText = ""
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Log in with your Subaru account")
                .font(.title)
            VStack {
                TextField("Email", text: $email)
                    .padding()
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .padding()
                Button {
                    Task {
                        if let loginResult = try? await client.logIn(username: email, password: password), loginResult.success, let data = loginResult.data {
                            appState.loggedIn = true
                            appState.deviceRegistered = data.deviceRegistered
                            appState.account = data.account
                            appState.vehicles = data.vehicles
                        } else {
                            alertActive = true
                            alertTitle = "Login failed"
                            alertText = "Please check your credentials and try again."
                        }
                    }
                } label: {
                    Text("Log in").frame(maxWidth: .infinity)
                }.padding().buttonStyle(.borderedProminent)
            }.frame(maxHeight: .infinity).padding()
            VStack {
                Text("\(emojiForRegion(appState.currentRegion))\t\(appState.currentRegion.rawValue)")
                Button("Change region") {
                    appState.currentRegion = .NotSelected
                }
            }
        }
        .alert(alertTitle, isPresented: $alertActive, actions: {
            Button("Dismiss") {}
        }, message: {
            Text(alertText)
        })
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject({ () -> AppState in
            let state = AppState()
            state.loggedIn = false
            state.currentRegion = .UnitedStates
            return state
        }())
    }
}
