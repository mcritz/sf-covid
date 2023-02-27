import Foundation

protocol SummaryViewRepresentable: ObservableObject {
    var caseCount: String { get }
    var lastUpdated: String { get }
    func update(_ days: Int?) async throws
}

#if DEBUG
final class PlaceHolderSummary: SummaryViewRepresentable {
    var caseCount = "\(Int.random(in: 1...10_000).formatted())"
    var lastUpdated = Date.now.formatted(.dateTime)
    func update(_ days: Int?) async throws {
        caseCount = "\(Int.random(in: 1...10_000).formatted())"
        lastUpdated = Date.now.formatted(.dateTime)
    }
}
#endif

final class SummaryViewModel: SummaryViewRepresentable {
    @Published var caseCount: String
    @Published var average: String
    @Published var lastUpdated: String
    @Published var chartValues: [Double] = []
    @Published var chartAvaerageValues: [Double] = []
    @Published var days: Int = 60
    private let covidData: CovidData
    private enum Constants: String {
        case ChartDays = "ChartDays"
    }
    
    enum Errors: Error {
        case dataError(reason: String)
    }
    
    private func getSavedDays() -> Int {
        let savedDays = UserDefaults.standard.integer(forKey: Constants.ChartDays.rawValue)
        guard savedDays > 0 else {
            return 60
        }
        return savedDays
    }
    
    @MainActor
    func update(_ userDays: Int? = nil) async throws {
        let days = userDays ?? getSavedDays()
        
        Task.detached(priority: .low) {
            UserDefaults.standard.setValue(days, forKey: Constants.ChartDays.rawValue)
        }
        let entries = try await covidData.update()
        let oneWeekAgoIndex = entries.count - 7
        let lastSeven = Array(entries[oneWeekAgoIndex...])
        self.average = String(average(lastSeven))
        self.caseCount = entries.last?.new_cases ?? "Error"
        self.lastUpdated = entries.last?.data_as_of?.formatted() ?? "Error"
        let numberToTrim = entries.count - days // days to display
        guard numberToTrim > 0,
              numberToTrim < entries.count else {
            throw Errors.dataError(reason: "Cannot drop more days than values exist")
        }
        let stepAlongTheWay = entries
            .dropFirst(numberToTrim)
            .filter { _ in
                true
        }
        let normals = covidData.normalize(stepAlongTheWay)
        self.chartValues = normals
    }
    
    private func average(_ entries: [CovidEntry]) -> Int {
        let sum = entries.reduce(into: 0) { prev, thisEntry in
            prev += (Int(thisEntry.new_cases) ?? 0)
        }
        let average = sum / entries.count
        return average
    }

    init() {
        self.covidData = CovidData()
        self.caseCount = ""
        self.lastUpdated = "Updating…"
        self.average = ""
        let savedDays = UserDefaults.standard.integer(forKey: Constants.ChartDays.rawValue)
        guard savedDays > 0 else {
            return
        }
        self.days = savedDays
        Task {
            try await update(days)
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
    
    enum Errors: Error {
        case noDirectory
    }
    
    enum Constants: String {
        case dataFileName = "data.json"
    }
    
    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.customSFData)
        self.decoder = decoder
        Task {
            try? await update()
        }
    }
    
    public func normalize(_ entries: [CovidEntry]) -> [Double] {
        let justCases = entries.map { entry in
            Double(entry.new_cases)
        }
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
    
    private func load(_ fileName: String = Constants.dataFileName.rawValue) throws -> Data {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw Errors.noDirectory
        }
        let sourceURL = directory.appendingPathComponent(fileName)
        let data = try Data(contentsOf: sourceURL)
        return data
    }
    
    private func save(_ data: Data, as fileName: String = Constants.dataFileName.rawValue) async throws {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw Errors.noDirectory
        }
        let destinationURL = directory.appendingPathComponent(fileName)
        try data.write(to: destinationURL)
    }
    
    @discardableResult
    func update() async throws -> [CovidEntry] {
        var someEntries = [CovidEntry]()
        let url = URL(string: "https://data.sfgov.org/resource/gyr2-k29z.json")!
        let request = URLRequest(url: url)
        do {
            // Load from the network
            let res = try await URLSession.shared.data(for: request, delegate: nil)
            try await save(res.0)
            someEntries = try decoder.decode([CovidEntry].self, from: res.0)
        } catch {
            // If network fails, try the local storage
            let data = try load()
            someEntries = try decoder.decode([CovidEntry].self, from: data)
        }
        let sortedEntries = someEntries.sorted(by: { alpha, brava in
            guard let apple = alpha.specimen_collection_date,
                  let banana = brava.specimen_collection_date else {
                return false
            }
            return apple < banana
        })
        self.chartNormalizedValues = normalize(sortedEntries)
        return sortedEntries
    }
}

struct CovidEntry: Codable {
    let specimen_collection_date: Date?
    let new_cases: String
    let cumulative_cases: String
    let data_as_of: Date?
//    let data_loaded_at: Date
}

