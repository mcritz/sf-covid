//
//  CovidHospitalizations.swift
//  SF Covid
//
//  Created by Michael Critz on 6/12/23.
//

import Foundation

// MARK: - CovidHospitalization
struct CovidHospitalization: Codable {
    let reportdate: String
    let dphcategory: Dphcategory
    let patientcount: Int
    let dataAsOf: Date
    let dataLoadedAt: Date

    enum CodingKeys: String, CodingKey {
        case reportdate, dphcategory, patientcount
        case dataAsOf = "data_as_of"
        case dataLoadedAt = "data_loaded_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reportdate = try container.decode(String.self, forKey: .reportdate)
        self.dphcategory = try container.decode(Dphcategory.self, forKey: .dphcategory)
        let countString = try container.decodeIfPresent(String.self, forKey: .patientcount)
        self.patientcount = Int(countString ?? "0") ?? 0
        self.dataAsOf = try container.decode(Date.self, forKey: .dataAsOf)
        self.dataLoadedAt = try container.decode(Date.self, forKey: .dataLoadedAt)
    }
}

extension CovidHospitalization: Chartable {
    var lastUpdated: Date {
        return dataAsOf
    }
    
    var count: Int? {
        return patientcount
    }
    
    var title: String {
        "Covid Hospitalizations"
    }
}

enum Dphcategory: String, Codable {
    case icu = "ICU"
    case medSurg = "Med/Surg"
}

typealias CovidHospitalizations = [CovidHospitalization]
