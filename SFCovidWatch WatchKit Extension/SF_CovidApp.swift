//
//  SF_CovidApp.swift
//  SFCovidWatch WatchKit Extension
//
//  Created by Michael Critz on 3/2/22.
//

import SwiftUI

@main
struct SF_CovidApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
        }

        WKNotificationScene(controller: NotificationController.self, category: "sfcovid")
    }
}
