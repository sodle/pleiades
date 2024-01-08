//
//  LoginView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/25/23.
//

import SwiftUI
import SubaruKit

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @State var rememberPassword = true
    
    @State var alertActive = false
    @State var alertTitle = ""
    @State var alertText = ""
    
    @EnvironmentObject var appState: AppState
    
    private func submit() {
        Task {
            if let loginResult = try? await client.logIn(username: email, password: password, rememberMe: rememberPassword), loginResult.success, let data = loginResult.data {
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
    }
    
    var body: some View {
        VStack {
            Text("Log in with your MySubaru account")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            Form {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                Toggle(isOn: $rememberPassword, label: {
                    Text("Remember my password")
                })
                Button(action: submit, label: {
                    Text("Submit")
                })
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }.frame(maxHeight: .infinity).scrollDisabled(true)
            VStack {
                Text("\(emojiForRegion(appState.currentRegion))\t\(appState.currentRegion.rawValue)")
                Button("Change region") {
                    appState.currentRegion = .NotSelected
                }
            }.padding()
        }
        .alert(alertTitle, isPresented: $alertActive, actions: {
            Button("Dismiss") {}
        }, message: {
            Text(alertText)
        })
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
