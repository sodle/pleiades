//
//  TwoFactorView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/26/23.
//

import SwiftUI

struct TwoFactorView: View {
    var preview = false
    
    @EnvironmentObject var appState: AppState
    
    @State var phoneFactor: String?
    @State var emailFactor: String?
    
    @State var verificationCode: String = ""
    @State var deviceName: String = UIDevice.current.model
    
    @State var alertActive = false
    @State var secondaryAlertActive = false
    @State var alertTitle = ""
    @State var alertText = ""
    @State var alertRetryable = false
    
    @State var authCodeSent = false
    
    @MainActor
    func loadFactors() async {
        if preview {
            emailFactor = "***@gmail.com"
            phoneFactor = "xxx-xxx-9999"
            return
        }
        
        if let factors = try? await client.getTwoFactorContacts(), factors.success, let data = factors.data {
            phoneFactor = data.phone
            emailFactor = data.userName
        } else {
            alertActive = true
            alertTitle = "Failed to retrieve two-factor authentication options"
            alertText = "Please try again later."
            alertRetryable = false
        }
    }
    
    var body: some View {
        VStack {
            Text("Verify your identity")
                .font(.title)
            VStack {
                if phoneFactor != nil {
                    Button {
                        Task {
                            if let requestTwoFactor = try? await client.requestTwoFactorCode(usingContactMethod: .sms), requestTwoFactor.success {
                                authCodeSent = true
                            } else {
                                alertActive = true
                                alertTitle = "Failed to request an authentication code"
                                alertText = "Please try again."
                                alertRetryable = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("📲")
                            Text("Text Message: \(phoneFactor!)")
                            Spacer()
                        }.frame(maxWidth: .infinity).padding()
                    }.buttonStyle(.bordered)
                }
                if emailFactor != nil {
                    Button {
                        Task {
                            if let requestTwoFactor = try? await client.requestTwoFactorCode(usingContactMethod: .email), requestTwoFactor.success {
                                authCodeSent = true
                            } else {
                                alertActive = true
                                alertTitle = "Failed to request an authentication code"
                                alertText = "Please try again."
                                alertRetryable = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("📩")
                            Text("Email: \(emailFactor!)")
                            Spacer()
                        }.frame(maxWidth: .infinity).padding()
                    }.buttonStyle(.bordered)
                }
            }.frame(maxHeight: .infinity).padding().popover(isPresented: $authCodeSent) {
                VStack {
                    Text("Enter the code we sent you")
                        .font(.title)
                        .padding()
                    VStack {
                        TextField("Verification code", text: $verificationCode)
                            .padding()
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                        VStack {
                            Text("Give this device a name:")
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            TextField("Device name", text: $deviceName)
                        }.padding()
                    }.frame(maxHeight: .infinity)
                    Button {
                        Task {
                            if let twoFactorResult = try? await client.verifyTwoFactorCode(code: verificationCode, deviceName: deviceName), twoFactorResult.success {
                                appState.deviceRegistered = true
                            } else {
                                secondaryAlertActive = true
                                alertTitle = "Failed to complete two-factor authentication"
                                alertText = "Please check your code and try again."
                                alertRetryable = true
                            }
                        }
                    } label: {
                        Text("Submit").frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .alert(alertTitle, isPresented: $secondaryAlertActive, actions: {
                        Button {
                            if !alertRetryable {
                                appState.loggedIn = false
                            }
                        } label: {
                            Text("Dismiss")
                        }
                    }) {
                        Text(alertText)
                    }
                }
            }
        }.padding().task {
            await loadFactors()
        }.alert(alertTitle, isPresented: $alertActive, actions: {
            Button {
                if !alertRetryable {
                    appState.loggedIn = false
                }
            } label: {
                Text("Dismiss")
            }
        }) {
            Text(alertText)
        }
    }
}

struct TwoFactorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TwoFactorView(preview: true)
            TwoFactorView(preview: true, authCodeSent: true)
                .previewDisplayName("Code Entry")
        }
    }
}
