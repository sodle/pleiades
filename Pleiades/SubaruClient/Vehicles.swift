//
//  Vehicles.swift
//  Pleiades
//
//  Created by Scott Odle on 2/26/23.
//

import Foundation
import Alamofire

public struct Account: Codable {
    let firstName: String
    let lastName: String
}

public struct VehicleStub: Codable {
    let vehicleName: String
    let vin: String
}

public struct RefreshVehiclesResponseData: Codable {
    let deviceRegistered: Bool
    let account: Account
    let vehicles: [VehicleStub]
}

public struct RefreshVehiclesResponse: Codable {
    let success: Bool
    let data: RefreshVehiclesResponseData
}

public func refreshVehicles() async throws -> RefreshVehiclesResponse {
    try await AF.request(SB_BASE_URL.appending(component: "refreshVehicles.json"))
        .serializingDecodable(RefreshVehiclesResponse.self)
        .value
}
