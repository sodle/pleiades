//
//  Authentication.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import Foundation

// MARK: - Validate session

public struct ValidateSessionResponse : Decodable {
    let success: Bool
}

// MARK: - Log in

public struct LoginRequest : FormDataEncodable {
    public func formParameters() -> [URLQueryItem] {
        [
            URLQueryItem(name: "loginUsername", value: loginUsername),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "deviceId", value: deviceID),
        ]
    }
    
    let loginUsername: String
    let password: String
    let deviceID: String
}

public struct LoginResponseData : Decodable {
    let deviceRegistered: Bool
    let account: Account
    let vehicles: [VehicleStub]
}

public struct LoginResponse : Decodable {
    let success: Bool
    let data: LoginResponseData?
}

// MARK: - Get two-step verification contacts

public struct TwoFactorContactsData: Decodable {
    let phone: String?
    let userName: String?
}

public struct TwoFactorContactsResponse: Decodable {
    let success: Bool
    let data: TwoFactorContactsData?
}

// MARK: - Send two-step verification code

public enum TwoFactorContactMethod: String {
    case sms = "phone"
    case email = "userName"
}

public struct SendTwoFactorRequest: FormDataEncodable {
    public func formParameters() -> [URLQueryItem] {
        [
            URLQueryItem(name: "contactMethod", value: contactMethod.rawValue),
        ]
    }
    
    let contactMethod: TwoFactorContactMethod
}

public struct SendTwoFactorResponse: Decodable {
    let success: Bool
}

// MARK: - Verify two-step verification code

public struct VerifyTwoFactorRequest: FormDataEncodable {
    public func formParameters() -> [URLQueryItem] {
        [
            URLQueryItem(name: "deviceId", value: deviceID),
            URLQueryItem(name: "deviceName", value: deviceName),
            URLQueryItem(name: "verificationCode", value: verificationCode),
            URLQueryItem(name: "rememberDevice", value: rememberDevice),
        ]
    }
    
    let deviceID: String
    let deviceName: String
    let verificationCode: String
    let rememberDevice: String
}

public struct VerifyTwoFactorResponse: Decodable {
    let success: Bool
}

// MARK: - Client implementation

extension Client {
    public func validateSession() async throws -> ValidateSessionResponse {
        let url = self.baseURL.appending(component: "validateSession.json")
        let request = Request<ValidateSessionResponse>(method: .get, url: url)
        return try await send(request)
    }
    
    public func logIn(username: String, password: String) async throws -> LoginResponse {
        let data = LoginRequest(loginUsername: username, password: password, deviceID: deviceID)
        let url = self.baseURL.appending(component: "login.json")
        let request = Request<LoginResponse>(method: .post, url: url, form: data)
        let response = try await send(request)
        self.saveCookie()
        return response
    }
    
    public func getTwoFactorContacts() async throws -> TwoFactorContactsResponse {
        let url = self.baseURL.appending(component: "twoStepAuthContacts.json")
        let request = Request<TwoFactorContactsResponse>(method: .get, url: url)
        return try await send(request)
    }
    
    public func requestTwoFactorCode(usingContactMethod contactMethod: TwoFactorContactMethod) async throws -> SendTwoFactorResponse {
        let data = SendTwoFactorRequest(contactMethod: contactMethod)
        let url = self.baseURL.appending(component: "twoStepAuthSendVerification.json")
        let request = Request<SendTwoFactorResponse>(method: .post, url: url, form: data)
        return try await send(request)
    }
    
    public func verifyTwoFactorCode(code: String, deviceName: String) async throws -> VerifyTwoFactorResponse {
        let data = VerifyTwoFactorRequest(deviceID: deviceID, deviceName: deviceName, verificationCode: code, rememberDevice: "on")
        let url = self.baseURL.appending(component: "twoStepAuthVerify.json")
        let request = Request<VerifyTwoFactorResponse>(method: .post, url: url, form: data)
        return try await send(request)
    }
}
