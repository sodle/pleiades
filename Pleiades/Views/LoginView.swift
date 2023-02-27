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
    
    @State var authCodeSent = false
    
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
                        let result = try! await logIn(username: email, password: password, deviceId: UIDevice.current.identifierForVendor!.uuidString)
                        if result.success {
                            appState.loggedIn = true
                            appState.deviceRegistered = result.data.deviceRegistered
                            appState.account = result.data.account
                            appState.vehicles = result.data.vehicles
                            saveCookie()
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
        }.padding()
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
