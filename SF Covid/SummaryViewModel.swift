import Foundation

protocol SummaryViewRepresentable: ObservableObject {
    var caseCount: String { get }
    var lastUpdated: String { get }
    func update() async throws
}

final class PlaceHolderSummary: SummaryViewRepresentable {
    var caseCount = "\(Int.random(in: 1...10_000).formatted())"
    var lastUpdated = Date.now.formatted(.dateTime)
    func update() async throws {
        caseCount = "\(Int.random(in: 1...10_000).formatted())"
        lastUpdated = Date.now.formatted(.dateTime)
    }
}

final class SummaryViewModel: SummaryViewRepresentable {
    @Published var caseCount: String
    @Published var lastUpdated: String
    private let covidData: CovidData
    
    @MainActor
    func update() async throws {
        let entries = try await covidData.update()
        self.caseCount = entries.last?.new_cases ?? "Error"
        self.lastUpdated = entries.last?.data_as_of?.formatted() ?? "Error"
    }

    init() {
        self.covidData = CovidData()
        self.caseCount = ""
        self.lastUpdated = "Updating…"
        
        Task {
            try await update()
        }
    }
}


final class CovidData: ObservableObject {
    @Published var entries = [CovidEntry]()
    private let decoder: JSONDecoder
    
    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.customSFData)
        self.decoder = decoder
        Task {
            try? await update()
        }
    }
    
    @discardableResult
    func update() async throws -> [CovidEntry] {
        let url = URL(string: "https://data.sfgov.org/resource/gyr2-k29z.json")!
        let request = URLRequest(url: url)
        let res = try await URLSession.shared.data(for: request, delegate: nil)
        self.entries = try decoder.decode([CovidEntry].self, from: res.0)
        return self.entries
    }
}

struct CovidEntry: Codable {
//    let specimen_collection_date: Date
    let new_cases: String
    let cumulative_cases: String
    let data_as_of: Date?
//    let data_loaded_at: Date
}

