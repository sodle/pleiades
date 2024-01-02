//
//  Cookies.swift
//  Pleiades
//
//  Created by Scott Odle on 1/2/24.
//

import Foundation

fileprivate let TOKEN_KEY = "PleiadesSessionToken"

extension Client {
    nonisolated func loadCookie() {
        if let sessionId = UserDefaults.standard.string(forKey: TOKEN_KEY) {
            if let cookie = HTTPCookie(properties: [
                .name: "JSESSIONID",
                .domain: self.baseURL.host()!,
                .secure: true,
                .path: "/",
                .port: baseURL.port ?? 443,
                .value: sessionId
            ]) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    nonisolated func saveCookie() {
        if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { cookie in
            cookie.name == "JSESSIONID"
        }) {
            UserDefaults.standard.setValue(cookie.value, forKey: TOKEN_KEY)
        }
    }
    
    nonisolated func clearCookie() {
        if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { cookie in
            cookie.name == "JSESSIONID"
        }) {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        UserDefaults.standard.setNilValueForKey(TOKEN_KEY)
    }
}
