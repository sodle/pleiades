//
//  Vehicles.swift
//  Pleiades
//
//  Created by Scott Odle on 2/26/23.
//

import Foundation
import CoreLocation

// MARK: - List vehicles for account

public struct Account: Codable {
    let firstName: String
    let lastName: String
}

public struct VehicleStub: Codable, Identifiable, Hashable {
    public var id: String {
        return vin
    }
    
    let vehicleName: String
    let vin: String
}

public struct RefreshVehiclesResponseData: Codable {
    let deviceRegistered: Bool
    let account: Account?
    let vehicles: [VehicleStub]?
}

public struct RefreshVehiclesResponse: Codable {
    let success: Bool
    let data: RefreshVehiclesResponseData?
}

// MARK: - Load a vehicle

public struct VehicleGeoPosition: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

public enum SubaruAPIGeneration: String {
    case g1
    case g2
    case g3
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
    
    var apiGeneration: SubaruAPIGeneration {
        if features.contains("g3") {
            return .g3
        }
        if features.contains("g2") {
            return .g2
        }
        return .g1
    }
}

public struct SelectVehicleResponse: Codable {
    let success: Bool
    let data: Vehicle?
}

// MARK: - Client implementation

extension Client {
    public func refreshVehicles() async throws -> RefreshVehiclesResponse {
        let url = self.baseURL.appending(component: "refreshVehicles.json")
        let request = Request<RefreshVehiclesResponse>(method: .get, url: url)
        return try await send(request)
    }
    
    public func selectVehicle(withVin vin: String) async throws -> SelectVehicleResponse {
        let url = self.baseURL.appending(component: "selectVehicle.json")
        let request = Request<SelectVehicleResponse>(method: .get, url: url, query: [
            "vin": vin,
        ])
        return try await send(request)
    }
}
