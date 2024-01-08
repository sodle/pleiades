//
//  Authentication.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import Foundation

// MARK: - Validate session

public struct ValidateSessionResponse : Decodable {
    public let success: Bool
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
    
    public let loginUsername: String
    public let password: String
    public let deviceID: String
}

public struct LoginResponseData : Decodable {
    public let deviceRegistered: Bool
    public let account: Account
    public let vehicles: [VehicleStub]
}

public struct LoginResponse : Decodable {
    public let success: Bool
    public let data: LoginResponseData?
}

// MARK: - Get two-step verification contacts

public struct TwoFactorContactsData: Decodable {
    public let phone: String?
    public let userName: String?
}

public struct TwoFactorContactsResponse: Decodable {
    public let success: Bool
    public let data: TwoFactorContactsData?
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
    
    public let contactMethod: TwoFactorContactMethod
}

public struct SendTwoFactorResponse: Decodable {
    public let success: Bool
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
    
    public let deviceID: String
    public let deviceName: String
    public let verificationCode: String
    public let rememberDevice: String
}

public struct VerifyTwoFactorResponse: Decodable {
    public let success: Bool
}

// MARK: - Client implementation

extension Client {
    public func validateSession() async throws -> ValidateSessionResponse {
        let url = self.baseURL.appending(component: "validateSession.json")
        let request = Request<ValidateSessionResponse>(method: .get, url: url)
        return try await send(request)
    }
    
    public func logIn(username: String, password: String, rememberMe: Bool = false) async throws -> LoginResponse {
        let data = LoginRequest(loginUsername: username, password: password, deviceID: deviceID)
        let url = self.baseURL.appending(component: "login.json")
        let request = Request<LoginResponse>(method: .post, url: url, form: data)
        let response = try await send(request)
        
        if rememberMe {
            saveCredentials(email: username, password: password)
        }
        
        return response
    }
    
    public func tryRestoreSession() async throws -> Bool {
        if let (email, password) = retrieveCredentials() {
            if let response = try? await logIn(username: email, password: password) {
                return response.success
            }
        }
        return false
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
