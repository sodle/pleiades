//
//  VehicleListView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/26/23.
//

import SwiftUI

struct VehicleListView: View {
    var preview = false
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if let account = appState.account {
            NavigationStack {
                if let vehicles = appState.vehicles {
                    List(vehicles) { vehicle in
                        NavigationLink(vehicle.vehicleName) {
                            VehicleDetailView(vehicle: vehicle, preview: preview)
                                .navigationTitle(vehicle.vehicleName)
                        }
                    }.navigationTitle("\(account.firstName)'s vehicles")
                }
            }
        }
    }
}

struct VehicleListView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleListView(preview: true).environmentObject({() -> AppState in
            let state = AppState()
            state.account = Account(firstName: "John", lastName: "Smith")
            state.vehicles = [
                VehicleStub(vehicleName: "John's WRX", vin: "VXXX")
            ]
            return state
        }())
    }
}
