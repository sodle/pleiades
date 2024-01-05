//
//  Keychain.swift
//  Pleiades
//
//  Created by Scott Odle on 1/5/24.
//

import Foundation

fileprivate enum CredentialType: String {
    case accountCredentials = "credential"
    case remoteServicesPin = "pin"
}

fileprivate func createAddQuery(_ credentialType: CredentialType, server: String, email: String, password: String) -> CFDictionary {
    return [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrType as String: credentialType.rawValue,
        kSecAttrServer as String: server,
        kSecAttrAccount as String: email,
        kSecValueData as String: password.data(using: .utf8)!,
    ] as CFDictionary
}

fileprivate func createSearchQuery(_ credentialType: CredentialType, server: String) -> CFDictionary {
    return [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrType as String: credentialType.rawValue,
        kSecAttrServer as String: server,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnAttributes as String: true,
        kSecReturnData as String: true,
    ] as CFDictionary
}

// MARK: - MySubaru account credentials

func saveCredentials(email: String, password: String) {
    let server = SB_BASE_URL.absoluteString
    
    let query = createAddQuery(.accountCredentials, server: server, email: email, password: password)
    let status = SecItemAdd(query, nil)
    
    guard status == errSecSuccess else {
        // TODO: HANDLE ERROR
        return
    }
}

func retrieveCredentials() -> (String, String)? {
    let server = SB_BASE_URL.absoluteString
    
    let query = createSearchQuery(.accountCredentials, server: server)
    var result: CFTypeRef?
    let status = SecItemCopyMatching(query, &result)
    
    guard status == errSecSuccess,
       let credential = result as? [String: Any],
       let email = credential[kSecAttrAccount as String] as? String,
       let passwordData = credential[kSecValueData as String] as? Data,
       let password = String(data: passwordData, encoding: .utf8) else
    {
        return nil
    }
    
    return (email, password)
}

// MARK: - Remote Services PIN

func savePIN(pin: String) {
    let server = SB_BASE_URL.absoluteString
    guard let (email, _) = retrieveCredentials() else {
        // TODO: HANDLE ERROR
        return
    }
    let pin_email = "PIN__\(email)"
    
    let query = createAddQuery(.remoteServicesPin, server: server, email: pin_email, password: pin)
    let status = SecItemAdd(query, nil)
    guard status == errSecSuccess else {
        // TODO: HANDLE ERROR
        return
    }
}

func retrievePIN() -> String? {
    let server = SB_BASE_URL.absoluteString
    
    let query = createSearchQuery(.remoteServicesPin, server: server)
    var result: CFTypeRef?
    let status = SecItemCopyMatching(query, &result)
    
    guard status == errSecSuccess,
          let credential = result as? [String: Any],
          let pinData = credential[kSecValueData as String] as? Data,
          let pin = String(data: pinData, encoding: .utf8) else {
        return nil
    }
    
    return pin
}

// MARK: - Clear saved credentials

func clearKeychain(server: String) {
    let query = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: server,
    ] as CFDictionary
    let status = SecItemDelete(query)
    guard status == errSecSuccess || status == errSecItemNotFound else {
        // TODO: HANDLE ERROR
        return
    }
}
