//
//  Cookies.swift
//  Pleiades
//
//  Created by Scott Odle on 1/2/24.
//

import Foundation

fileprivate let COOKIE_KEY = "PleiadesCookies"

extension Client {
    nonisolated func loadCookie() {
        if let storedCookies = UserDefaults.standard.array(forKey: COOKIE_KEY) {
            if let cookieStorage = session.configuration.httpCookieStorage {
                storedCookies.forEach { storedCookie in
                    if let cookieProperties = storedCookie as? [HTTPCookiePropertyKey: Any] {
                        if let cookie = HTTPCookie(properties: cookieProperties) {
                            cookieStorage.setCookie(cookie)
                        }
                    }
                }
            }
        }
    }
    
    nonisolated func saveCookie() {
        if let cookies = session.configuration.httpCookieStorage?.cookies {
            let cookieProperties = cookies.map { cookie in
                cookie.properties
            }
            UserDefaults.standard.setValue(cookieProperties, forKey: COOKIE_KEY)
        }
    }
    
    nonisolated func clearCookie() {
        if let cookieStore = session.configuration.httpCookieStorage {
            if let cookies = cookieStore.cookies {
                cookies.forEach { cookie in
                    cookieStore.deleteCookie(cookie)
                }
            }
        }
        UserDefaults.standard.setNilValueForKey(COOKIE_KEY)
    }
}
