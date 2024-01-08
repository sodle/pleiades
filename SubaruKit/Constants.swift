//
//  Constants.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import Foundation

let SB_API_VERSION = "g2v29"

public enum SBRegion: String, CaseIterable {
    case UnitedStates = "United States"
    case Canada = "Canada"
    case Test = "Test Server"
    case Local = "Local Test"
    case NotSelected = "Not Selected"
}

fileprivate let REGION_KEY = "PleiadesRegion"
public var SB_CURRENT_REGION: SBRegion {
    get {
        if let regionName = UserDefaults().string(forKey: REGION_KEY) {
            if let region = SBRegion(rawValue: regionName) {
                return region
            }
        }
        
        if let locale = Locale.current.region {
            if locale == .canada {
                return .Canada
            }
        }
        
        return .UnitedStates
    }
    set(newValue) {
        UserDefaults().set(newValue.rawValue, forKey: REGION_KEY)
    }
}

public func emojiForRegion(_ region: SBRegion) -> String {
    switch region {
    case .UnitedStates:
        return "🇺🇸"
    case .Canada:
        return "🇨🇦"
    case .Test:
        return "💾"
    case .Local:
        return "💻"
    case .NotSelected:
        return "❓"
    }
}

public var SB_BASE_URL: URL {
    switch SB_CURRENT_REGION {
    case .UnitedStates:
        return URL(string: "https://mobileapi.prod.subarucs.com")!.appending(component: SB_API_VERSION)
    case .Canada:
        return URL(string: "https://mobileapi.ca.prod.subarucs.com")!.appending(component: SB_API_VERSION)
    case .Test:
        return URL(string: "https://pleiades-test.sjodle.com")!.appending(component: SB_API_VERSION)
    case .Local:
        return URL(string: "http://localhost:5000")!.appending(component: SB_API_VERSION)
    case .NotSelected:
        return URL(string: "")!
    }
}
