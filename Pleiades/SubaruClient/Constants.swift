//
//  Constants.swift
//  Pleiades
//
//  Created by Scott Odle on 2/18/23.
//

import Foundation

let API_VERSION = "g2v24"

public var SB_USE_CANADA: Bool {
    get {
        UserDefaults().bool(forKey: "SBUseCanada")
    }
    set(newValue) {
        UserDefaults().set(newValue, forKey: "SBUseCanada")
    }
}

public var SB_BASE_URL: URL {
    if SB_USE_CANADA {
        return URL(string: "https://mobileapi.ca.prod.subarucs.com")!.appending(component: API_VERSION)
    } else {
        return URL(string: "https://mobileapi.prod.subarucs.com")!.appending(component: API_VERSION)
    }
}
