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
    @Published var chartValues: [Double] = []
    private let covidData: CovidData
    
    @MainActor
    func update() async throws {
        let entries = try await covidData.update()
        self.caseCount = entries.last?.new_cases ?? "Error"
        self.lastUpdated = entries.last?.data_as_of?.formatted() ?? "Error"
        let numberToTrim = covidData.chartNormalizedValues.count - 60 // days to display
        let stepAlongTheWay = covidData.chartNormalizedValues.dropFirst(numberToTrim)
        self.chartValues = Array(stepAlongTheWay)
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
    @Published var entries = [CovidEntry]() {
        didSet {
            chartNormalizedValues = normalize(entries)
        }
    }
    @Published var chartNormalizedValues: [Double] = []
    private let decoder: JSONDecoder
    
    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.customSFData)
        self.decoder = decoder
        Task {
            try? await update()
        }
    }
    
    private func normalize(_ entries: [CovidEntry]) -> [Double] {
        let justCases = entries.map({ entry in
            Double(entry.new_cases)
        })
        let highest = justCases.reduce(into: 0.0) { partialResult, next in
            guard let next = next,
                  next > partialResult else {
                return
            }
            partialResult = next
        }
        // 1, 2, 3
        let scaleFactor = highest == 0 ? 1 : highest
        // scaleFactor = 3
        let normalizedValues = justCases.map { value in
            (value ?? 0) / scaleFactor // 1/3, 2/3, 1.0
        }
        return normalizedValues
    }
    
    @discardableResult
    func update() async throws -> [CovidEntry] {
        let url = URL(string: "https://data.sfgov.org/resource/gyr2-k29z.json")!
        let request = URLRequest(url: url)
        let res = try await URLSession.shared.data(for: request, delegate: nil)
        let someEntries = try decoder.decode([CovidEntry].self, from: res.0)
        self.entries = someEntries.sorted(by: { alpha, brava in
            guard let apple = alpha.specimen_collection_date,
                  let banana = brava.specimen_collection_date else {
                return false
            }
            return apple < banana
        })
        return self.entries
    }
}

struct CovidEntry: Codable {
    let specimen_collection_date: Date?
    let new_cases: String
    let cumulative_cases: String
    let data_as_of: Date?
//    let data_loaded_at: Date
}

