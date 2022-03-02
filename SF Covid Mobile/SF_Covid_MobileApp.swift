//
//  SF_Covid_MobileApp.swift
//  SF Covid Mobile
//
//  Created by Michael Critz on 2/28/22.
//

import SwiftUI

@main
struct SF_Covid_MobileApp: App {
    @ObservedObject var summaryViewModel = SummaryViewModel()
    var body: some Scene {
        WindowGroup {
            SummaryView()
                .environmentObject(summaryViewModel)
        }
    }
}
