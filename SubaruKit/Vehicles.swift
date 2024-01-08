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
    public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    public let firstName: String
    public let lastName: String
}

public struct VehicleStub: Codable, Identifiable, Hashable {
    public init(vehicleName: String, vin: String) {
        self.vehicleName = vehicleName
        self.vin = vin
    }
    
    public var id: String {
        return vin
    }
    
    public let vehicleName: String
    public let vin: String
}

public struct RefreshVehiclesResponseData: Codable {
    public let deviceRegistered: Bool
    public let account: Account?
    public let vehicles: [VehicleStub]?
}

public struct RefreshVehiclesResponse: Codable {
    public let success: Bool
    public let data: RefreshVehiclesResponseData?
}

// MARK: - Load a vehicle

public struct VehicleGeoPosition: Codable {
    public init(latitude: Double, longitude: Double, timestamp: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
    
    public let latitude: Double
    public let longitude: Double
    public let timestamp: String
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

public enum SubaruAPIGeneration: String {
    case g1
    case g2
    case g3
}

public struct Vehicle: Codable, Identifiable {
    public init(vehicleName: String, vin: String, licensePlate: String, licensePlateState: String, features: [String], modelYear: String, modelName: String, transCode: String, extDescrip: String, timeZone: String, vehicleGeoPosition: VehicleGeoPosition) {
        self.vehicleName = vehicleName
        self.vin = vin
        self.licensePlate = licensePlate
        self.licensePlateState = licensePlateState
        self.features = features
        self.modelYear = modelYear
        self.modelName = modelName
        self.transCode = transCode
        self.extDescrip = extDescrip
        self.timeZone = timeZone
        self.vehicleGeoPosition = vehicleGeoPosition
    }
    
    public var id: String {
        return vin
    }
    
    public let vehicleName: String
    
    public let vin: String
    public let licensePlate: String
    public let licensePlateState: String
    
    public let features: [String]
    
    public let modelYear: String
    public let modelName: String
    public let transCode: String
    public let extDescrip: String
    
    public let timeZone: String
    public let vehicleGeoPosition: VehicleGeoPosition
    
    public var apiGeneration: SubaruAPIGeneration {
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
    public let success: Bool
    public let data: Vehicle?
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
