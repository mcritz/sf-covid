import Foundation

actor CovidData: ObservableObject {
    @Published var entries = [CovidEntry]() {
        didSet {
            chartNormalizedValues = normalize(entries)
        }
    }
    @Published var chartNormalizedValues: [Double] = []
    private var scaleFactor: Double = 1.0
    private let decoder: JSONDecoder
    
    enum Errors: Error {
        case noDirectory
        case networkError(reason: String, entries: [CovidEntry])
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
//            var request = URLRequest(url: url)
//            request.cachePolicy = .reloadRevalidatingCacheData
            let res = try Data(contentsOf: url)
//            let (url, res) = try await URLSession.shared.download(for: request)
            try await save(res)
            someEntries = try decoder.decode([CovidEntry].self, from: res)
        } catch {
            print("xxx \(error)")
            // If network fails, try the local storage
            if let data = try? load() {
                someEntries = try decoder.decode([CovidEntry].self, from: data)
                someEntries = sort(someEntries)
                self.chartNormalizedValues = normalize(someEntries)
            }
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
            Double(entry.new_cases) ?? 0.0
        }
        scaleFactor = getScaleFactor(justCases)
        return normalize(justCases)
    }
    
    private func getScaleFactor(_ numbers: [Double]) -> Double {
        let largestValue = numbers.reduce(into: 0.0) { partialResult, next in
            guard next > partialResult else {
                return
            }
            partialResult = next
        }
        let scaleFactor = largestValue == 0 ? 1 : largestValue
        return scaleFactor
    }
    
    public func normalize(_ numbers: [Double]) -> [Double] {
        let normalizedValues = numbers.map { value in
            value / scaleFactor // 1/3, 2/3, 1.0
        }
        return normalizedValues
    }
    
    private func load(_ fileName: String = Constants.dataFileName.rawValue) throws -> Data {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw Errors.noDirectory
        }
        let sourceURL = directory.appendingPathComponent(fileName)
        if !FileManager.default.isReadableFile(atPath: sourceURL.path) {
            FileManager.default.createFile(atPath: sourceURL.path, contents: nil)
        }
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
