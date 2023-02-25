//
//  Authentication.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import Foundation
import Alamofire

public struct ValidateSessionResponse : Codable {
    let success: Bool
}

public func validateSession() async throws -> ValidateSessionResponse {
    try await AF.request(SB_BASE_URL.appending(component: "validateSession.json"))
        .serializingDecodable(ValidateSessionResponse.self)
        .value
}

public struct LogInResponseData : Codable {
    let deviceRegistered: Bool
}

public struct LogInResponse : Codable {
    let success: Bool
    let data: LogInResponseData
}

public func logIn(username: String, password: String, deviceId: String) async throws -> LogInResponse {
    try await AF.request(SB_BASE_URL.appending(component: "login.json"), method: .post, parameters: [
        "loginUsername": username,
        "password": password,
        "deviceId": deviceId
    ])
        .serializingDecodable(LogInResponse.self)
        .value
}
