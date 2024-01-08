//
//  VehicleListView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/26/23.
//

import SwiftUI
import SubaruKit

fileprivate let LAST_VEHICLE_KEY = "PleiadesLastVehicle"

enum Route: Hashable {
    case list
    case detail(VehicleStub)
}

struct VehicleListView: View {
    @State private var path = NavigationPath([Route.list])
    var preview = false
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if let account = appState.account {
            if let vehicles = appState.vehicles {
                NavigationStack(path: $path) {
                    VStack {}.navigationDestination(for: Route.self) { route in
                        switch route {
                        case .list:
                            List(vehicles) { vehicle in
                                NavigationLink(vehicle.vehicleName, value: Route.detail(vehicle)).onSubmit {
                                    UserDefaults.standard.setValue(vehicle.vin, forKey: LAST_VEHICLE_KEY)
                                }
                            }.navigationTitle("\(account.firstName)'s vehicles")
                                .navigationBarBackButtonHidden()
                        case .detail(let vehicle):
                            VehicleDetailView(vehicle: vehicle, preview: preview)
                                .navigationTitle(vehicle.vehicleName)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }.onAppear {
                    if let lastVin = UserDefaults.standard.string(forKey: LAST_VEHICLE_KEY) {
                        if let vehicleStub = vehicles.first(where: { vehicle in
                            vehicle.vin == lastVin
                        }) {
                            path.append(Route.detail(vehicleStub))
                        }
                    } else if vehicles.count == 1, let onlyVehicle = vehicles.first {
                        path.append(Route.detail(onlyVehicle))
                    }
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
                VehicleStub(vehicleName: "John's WRX", vin: "VXXX"),
                VehicleStub(vehicleName: "Tony's Outback", vin: "VYYYY")
            ]
            return state
        }())
    }
}
