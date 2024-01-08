//
//  TelematicsG2.swift
//  Pleiades
//
//  Created by Scott Odle on 1/4/24.
//

import Foundation

fileprivate let g2BaseUrl = SB_BASE_URL.appending(component: "service").appending(component: "g2")

// MARK: - Request Status API

public struct RequestStatusResponseDataG2: Decodable {
    public let remoteServiceState: String
}

public struct RequestStatusResponseG2: Decodable {
    public let success: Bool
    public let data: RequestStatusResponseDataG2?
}

// MARK: - Door Lock API

public enum DoorCommandTargetG2: String, Encodable {
    case allDoors = "ALL_DOORS_CMD"
    case driverDoor = "FRONT_LEFT_DOOR_CMD"
}

public struct UnlockDoorsRequestG2: Encodable {
    public let pin: String
    public let unlockDoorType: DoorCommandTargetG2
}

public struct UnlockDoorsResponseDataG2: Decodable {
    public let serviceRequestId: String
    public let success: Bool
    public let cancelled: Bool
    public let remoteServiceState: String
}

public struct UnlockDoorsResponseG2: Decodable {
    public let success: Bool
    public let data: UnlockDoorsResponseDataG2?
}

// MARK: - Client implementation

extension Client {
    public func getRequestStatusG2(requestId: String) async throws -> RequestStatusResponseG2 {
        let url = g2BaseUrl.appending(component: "remoteService").appending(component: "status.json")
        let request = Request<RequestStatusResponseG2>(method: .get, url: url, query: [
            "serviceRequestId": requestId,
        ])
        return try await send(request)
    }
    
    public func unlockDoorsG2(vin: String, pin: String, doors: DoorCommandTargetG2) async throws -> UnlockDoorsResponseG2 {
        if let selectVehicleResponse = try? await selectVehicle(withVin: vin), selectVehicleResponse.success == true {
            let data = UnlockDoorsRequestG2(pin: pin, unlockDoorType: doors)
            let url = g2BaseUrl.appending(component: "unlock").appending(component: "execute.json")
            let request = Request<UnlockDoorsResponseG2>(method: .post, url: url, body: data)
            return try await send(request)
        } else {
            return UnlockDoorsResponseG2(success: false, data: nil)
        }
    }
}
