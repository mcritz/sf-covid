import Foundation

struct CovidEntry: Codable {
    let specimen_collection_date: Date?
    let new_cases: String
    let cumulative_cases: String
    let data_as_of: Date?
}

extension CovidEntry: Chartable {
    var count: Int? {
        return Int(new_cases)
    }
    var lastUpdated: Date {
        return data_as_of ?? Date.now
    }
    var title: String {
        "New Covid Cases"
    }
}
