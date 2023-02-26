//
//  RegionSelectView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/25/23.
//

import SwiftUI

struct RegionSelectView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Select your region:")
            ForEach(SBRegion.allCases.filter {$0 != .NotSelected}, id: \.rawValue) { region in
                Button("\(emojiForRegion(region))\t\(region.rawValue)") {
                    SB_CURRENT_REGION = region
                    appState.currentRegion = region
                }.buttonStyle(.bordered)
            }
        }
    }
}

struct RegionSelectView_Previews: PreviewProvider {
    static var previews: some View {
        RegionSelectView()
    }
}
