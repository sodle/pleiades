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

public func saveCookie() {
    if let cookies = HTTPCookieStorage.shared.cookies {
        for cookie in cookies {
            if cookie.name == "JSESSIONID" {
                UserDefaults().set(cookie.value, forKey: "SessionCookie")
            }
        }
    }
}

public func loadCookie() {
    if let domain = SB_BASE_URL.host() {
        if let sessionId = UserDefaults().string(forKey: "SessionCookie") {
            if let cookie = HTTPCookie(properties: [
                .name: "JSESSIONID",
                .domain: domain,
                .secure: true,
                .path: "/" + SB_API_VERSION,
                .value: sessionId
            ]) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
}

public struct LogInResponseData : Codable {
    let deviceRegistered: Bool
    let account: Account
    let vehicles: [VehicleStub]
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

public struct TwoFactorContactsData: Codable {
    let phone: String?
    let userName: String?
}

public struct TwoFactorContactsResponse: Codable {
    let success: Bool
    let data: TwoFactorContactsData
}

public func getTwoFactorContacts() async throws -> TwoFactorContactsResponse {
    try await AF.request(SB_BASE_URL.appending(component: "twoStepAuthContacts.json"), method: .get)
        .serializingDecodable(TwoFactorContactsResponse.self)
        .value
}

public enum TwoFactorContactMethod: String {
    case sms = "phone"
    case email = "userName"
}

public struct SendTwoFactorResponse: Codable {
    let success: Bool
}

public func sendTwoFactorCode(usingContactMethod contactMethod: TwoFactorContactMethod) async throws -> SendTwoFactorResponse {
    try await AF.request(SB_BASE_URL.appending(component: "twoStepAuthSendVerification.json"), method: .post, parameters: [
        "contactMethod": contactMethod.rawValue
    ])
    .serializingDecodable(SendTwoFactorResponse.self)
    .value
}

public struct VerifyTwoFactorResponse: Codable {
    let success: Bool
}

public func verifyTwoFactorCode(deviceId: String, verificationCode: String, deviceName: String) async throws -> VerifyTwoFactorResponse {
    try await AF.request(SB_BASE_URL.appending(component: "twoStepAuthVerify.json"), method: .post, parameters: [
        "deviceId": deviceId,
        "deviceName": deviceName,
        "verificationCode": verificationCode,
        "rememberDevice": "on"
    ])
    .serializingDecodable(VerifyTwoFactorResponse.self)
    .value
}
