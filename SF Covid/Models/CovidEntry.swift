import Foundation

struct CovidEntry: Codable {
    let specimen_collection_date: Date?
    let new_cases: String
    let cumulative_cases: String
    let data_as_of: Date?
//    let data_loaded_at: Date
}

