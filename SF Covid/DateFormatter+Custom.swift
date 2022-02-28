//
//  DateFormatter+Custom.swift
//  SF Covid
//
//  Created by Michael Critz on 2/23/22.
//

import Foundation

extension DateFormatter {
    static let customSFData: DateFormatter = {
        let formatter = DateFormatter()
        // Example from API: 2022-02-23T04:30:01.180
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
