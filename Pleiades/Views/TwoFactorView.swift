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
    
    @State var authCodeSent = false
    
    @MainActor
    func loadFactors() async {
        if preview {
            emailFactor = "***@gmail.com"
            phoneFactor = "xxx-xxx-9999"
            return
        }
        
        let factors = try! await getTwoFactorContacts()
        phoneFactor = factors.data.phone
        emailFactor = factors.data.userName
    }
    
    var body: some View {
        VStack {
            Text("Verify your identity")
                .font(.title)
            VStack {
                if phoneFactor != nil {
                    Button {
                        if !preview {
                            Task {
                                try! await sendTwoFactorCode(usingContactMethod: .sms)
                            }
                        }
                        authCodeSent = true
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
                        if !preview {
                            Task {
                                try! await sendTwoFactorCode(usingContactMethod: .email)
                            }
                        }
                        authCodeSent = true
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
                            if !preview {
                                let twoFactorResult = try! await verifyTwoFactorCode(
                                    deviceId: UIDevice.current.identifierForVendor!.uuidString,
                                    verificationCode: verificationCode,
                                    deviceName: deviceName
                                )
                                if twoFactorResult.success {
                                    appState.deviceRegistered = true
                                    saveCookie()
                                }
                            }
                        }
                    } label: {
                        Text("Submit").frame(maxWidth: .infinity)
                    }.padding().buttonStyle(.borderedProminent)
                }
            }
        }.padding().task {
            await loadFactors()
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
