import Foundation

actor CovidData: ObservableObject {
    @Published var entries = [CovidEntry]() {
        didSet {
            chartNormalizedValues = normalize(entries)
        }
    }
    @Published var chartNormalizedValues: [Double] = []
    private let decoder: JSONDecoder
    
    enum Errors: Error {
        case noDirectory
        case networkError(reason: String, entries: [CovidEntry])
    }
    
    enum Constants: String {
        case dataFileName = "data.json"
        case apiURL = "https://data.sfgov.org/resource/gyr2-k29z.json?$limit=3000"
    }
    
    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.customSFData)
        self.decoder = decoder
        Task {
            try? await update()
        }
    }
    
    @discardableResult
    public func update() async throws -> Result<[CovidEntry], Errors> {
        var someEntries = [CovidEntry]()
        let url = URL(string: Constants.apiURL.rawValue)!
        do {
            // Load from the network
            let res = try Data(contentsOf: url)
            try await save(res)
            someEntries = try decoder.decode([CovidEntry].self, from: res)
        } catch {
            // If network fails, try the local storage
            let data = try load()
            someEntries = try decoder.decode([CovidEntry].self, from: data)
            someEntries = sort(someEntries)
            self.chartNormalizedValues = normalize(someEntries)
            return .failure(.networkError(reason: "Network error", entries: someEntries))
        }
        let sortedEntries = sort(someEntries)
        self.chartNormalizedValues = normalize(sortedEntries)
        return .success(sortedEntries)
    }
    
    /// This method transforms values to be usable by `Charts` library by mapping  `[CovidEntry]` to values in range `0...1`
    /// Example: Case counts like `[1, 10, 100]` will map to `[0.01, 0.1, 1.0]`
    /// - Parameter entries: `[CovidEntry]`
    /// - Returns: `[Double]`
    public func normalize(_ entries: [CovidEntry]) -> [Double] {
        let justCases = entries.map { entry in
            Double(entry.new_cases)
        }
        
        let largestValue = justCases.reduce(into: 0.0) { partialResult, next in
            guard let next = next,
                  next > partialResult else {
                return
            }
            partialResult = next
        }
        // 1, 2, 3
        // scaleFactor = 3
        let scaleFactor = largestValue == 0 ? 1 : largestValue
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
    
    private func sort(_ entries: [CovidEntry]) -> [CovidEntry] {
        let sortedEntries = entries.sorted(by: { alpha, brava in
            guard let apple = alpha.specimen_collection_date,
                  let banana = brava.specimen_collection_date else {
                return false
            }
            return apple < banana
        })
        return sortedEntries
    }
}
