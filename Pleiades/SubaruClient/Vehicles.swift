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

public struct VehicleStub: Codable, Identifiable {
    public var id: String {
        return vin
    }
    
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

public struct VehicleGeoPosition: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: String
}

public struct Vehicle: Codable, Identifiable {
    public var id: String {
        return vin
    }
    
    let vehicleName: String
    
    let vin: String
    let licensePlate: String
    let licensePlateState: String
    
    let features: [String]
    
    let modelYear: String
    let modelName: String
    let transCode: String
    let extDescrip: String
    
    let timeZone: String
    let vehicleGeoPosition: VehicleGeoPosition
}

public struct SelectVehicleResponse: Codable {
    let success: Bool
    let data: Vehicle
}

public func selectVehicle(vin: String) async throws -> SelectVehicleResponse {
    try await AF.request(SB_BASE_URL.appending(component: "selectVehicle.json"), method: .get, parameters: [
        "vin": vin
    ])
    .serializingDecodable(SelectVehicleResponse.self)
    .value
}
