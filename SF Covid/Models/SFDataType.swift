//
//  DataType.swift
//  SF Covid
//
//  Created by Michael Critz on 6/14/23.
//

import Foundation

public enum SFDataType {
    case covidTest
    case covidHospitalizations
    
    var fileURL: URL? {
        switch self {
        case .covidTest:
            return try? FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("covid-cases.json")
        case .covidHospitalizations:
            return try? FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("covid-hospitalizations.json")
        }
    }
    
    var url: URL {
        switch self {
        case .covidTest:
            return URL(string: Constants.casesURL.rawValue)!
        case .covidHospitalizations:
            return URL(string: Constants.hospitalizationsURL.rawValue)!
        }
    }
}
