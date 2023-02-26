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
