//
//  TelematicsViewG2.swift
//  Pleiades
//
//  Created by Scott Odle on 1/4/24.
//

import SwiftUI

struct TelematicsButtonG2: View {
    // Request function should take the VIN and remote services PIN, initiate the target remote command, and return a nullable request ID to check the status of the command.
    let label: String
    let vin: String
    let width: Int = 1
    let requestFunction: ((String, String) async throws -> String?)
    
    @State private var pin: String = retrievePIN() ?? ""
    
    @State private var pinPromptActive = false
    @State private var loading = false
    @State private var failed = false
    @State private var success = false
    
    private func setResetTimer(_ seconds: Int = 2) {
        Task {
            try await Task.sleep(for: .seconds(seconds))
            pinPromptActive = false
            loading = false
            failed = false
            success = false
        }
    }
    
    private func onClick() {
        pinPromptActive = false
        failed = false
        success = false
        loading = true
        
        // if the pin isn't empty, try to get it from the keychain
        if pin.isEmpty {
            pin = retrievePIN() ?? ""
        }
        
        // if it's still empty, prompt for it
        if pin.isEmpty {
            pinPromptActive = true
        } else {
            onGetPin(pin)
        }
    }
    
    private func onGetPin(_ pin: String, preserve: Bool = false) {
        Task {
            if let requestId = try? await requestFunction(vin, pin) {
                for n in 0..<100 {
                    try await Task.sleep(for: .seconds(0.5))
                    if let status = try? await client.getRequestStatusG2(requestId: requestId), status.success, let data = status.data {
                        print(n, data.remoteServiceState)
                        if data.remoteServiceState == "started" {
                            continue
                        } else if data.remoteServiceState == "finished" {
                            loading = false
                            success = true
                            if preserve {
                                savePIN(pin: pin)
                            }
                            setResetTimer()
                            break
                        } else {
                            loading = false
                            failed = true
                            setResetTimer(10)
                            break
                        }
                    } else {
                        loading = false
                        failed = true
                        setResetTimer(10)
                        break
                    }
                }
            } else {
                loading = false
                failed = true
                setResetTimer(10)
            }
        }
    }
    
    var body: some View {
        Button(action: onClick, label: {
            if success {
                Image(systemName: "checkmark.circle")
            } else if failed {
                Image(systemName: "exclamationmark.circle")
            } else if loading {
                Image(systemName: "ellipsis.circle")
            } else {
                Text(label)
            }
        })
        .buttonStyle(.borderedProminent)
        .tint({
            if success {
                .green
            } else if failed {
                .red
            } else {
                .accentColor
            }
        }())
        .disabled(loading)
        .gridCellColumns(width)
        .alert("Enter your PIN", isPresented: $pinPromptActive) {
            SecureField("STARLINK PIN", text: $pin)
                .keyboardType(.numberPad)
            Button("Save PIN") {
                loading = true
                onGetPin(pin, preserve: true)
            }
            Button("Submit without saving PIN") {
                loading = true
                onGetPin(pin)
                // Clear the PIN, if the user doesn't want it in memory
                pin = ""
            }
            Button("Cancel", role: .cancel, action: {
                // Clear any PIN that may have been entered
                pin = ""
            })
        }
    }
}

struct TelematicsViewG2: View {
    let vin: String
    @State private var pin: String = ""
    
    @FocusState private var pinFocused: Bool
    
    var body: some View {
        Grid {
            GridRow {
                TelematicsButtonG2(label: "Unlock all doors", vin: vin) { vin, pin in
                    if let response = try? await client.unlockDoorsG2(vin: vin, pin: pin, doors: .allDoors), response.success, let data = response.data {
                        return data.serviceRequestId
                    }
                    return nil
                }
                TelematicsButtonG2(label: "Unlock driver door", vin: vin) { vin, pin in
                    if let response = try? await client.unlockDoorsG2(vin: vin, pin: pin, doors: .driverDoor), response.success, let data = response.data {
                        return data.serviceRequestId
                    }
                    return nil
                }
            }
        }
    }
}

#Preview {
    TelematicsViewG2(vin: "FAKEVIN")
}
