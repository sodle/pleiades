//
//  TopLevelErrorView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/25/23.
//

import SwiftUI

struct TopLevelErrorView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Failed to initialize the app!")
            Text("Switching regions sometimes fixes this.")
            Button("Switch region") {
                appState.currentRegion = .NotSelected
            }.buttonStyle(.borderedProminent)
        }
    }
}

struct TopLevelErrorView_Previews: PreviewProvider {
    static var previews: some View {
        TopLevelErrorView()
    }
}
