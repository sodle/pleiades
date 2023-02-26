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
            Text("Select your region")
                .font(.title)
            VStack {
                ForEach(SBRegion.allCases.filter {$0 != .NotSelected}, id: \.rawValue) { region in
                    Button {
                        SB_CURRENT_REGION = region
                        appState.currentRegion = region
                    } label: {
                        HStack {
                            Text(emojiForRegion(region))
                            Text(region.rawValue)
                            Spacer()
                        }.frame(maxWidth: .infinity).padding()
                    }.buttonStyle(.bordered)
                }
            }.frame(maxHeight: .infinity).padding()
        }.padding()
    }
}

struct RegionSelectView_Previews: PreviewProvider {
    static var previews: some View {
        RegionSelectView()
    }
}
