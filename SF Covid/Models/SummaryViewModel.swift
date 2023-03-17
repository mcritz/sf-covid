import Foundation
import SwiftUI

final class SummaryViewModel: SummaryViewRepresentable {
    @Published var status: Status = .pristine
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
        case networkError(reason: String)
    }
    
    private func getSavedDays() -> Int {
        let savedDays = UserDefaults.standard.integer(forKey: Constants.ChartDays.rawValue)
        guard savedDays > 0 else {
            return 60
        }
        return savedDays
    }
    
    private func rollingAverage(_ source: [CovidEntry]) -> [Double] {
        var rollingAverage = [Double]()
        var averages = [Int]()
        for entry in source {
            guard let value = Int(entry.new_cases) else {
                continue
            }
            if averages.count > 6 {
                averages.removeFirst()
            }
            averages.append(value)
            let thisAverage = average(numbers: averages)
            rollingAverage.append(thisAverage)
        }
        return rollingAverage
    }
    
    func average(numbers: [Int]) -> Double {
        let sum = numbers.reduce(into: 0) { partialResult, thisInt in
            partialResult += thisInt
        }
        return Double(sum) / Double(numbers.count)
    }

    
    @MainActor
    func update(_ userDays: Int? = nil) async throws {
        withAnimation(.spring()) {
            status = .loading
        }
        let days = userDays ?? getSavedDays()
        
        Task.detached(priority: .low) {
            UserDefaults.standard.setValue(days, forKey: Constants.ChartDays.rawValue)
        }
        
        do {
            let updateResult = try await covidData.update()
            let entries: [CovidEntry]!
            switch updateResult {
            case .success(let networkEntries):
                entries = networkEntries
            case .failure(.networkError(reason: let reason, entries: let savedEntries)):
                entries = savedEntries
                self.lastUpdated = reason
            case .failure(.noDirectory):
                self.lastUpdated = "Error"
                self.status = .error
                return
            }
            // Get a seven day average
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
            let stepAlongTheWay = Array(entries.dropFirst(numberToTrim))
            let rollingAverages = rollingAverage(stepAlongTheWay)
            let normals = await covidData.normalize(stepAlongTheWay)
            let normalizedRollingAverages = await covidData.normalize(rollingAverages)
            withAnimation(.spring()) {
                self.status = .ready
                self.chartValues = normals
                self.chartAvaerageValues = normalizedRollingAverages
            }
        } catch {
            self.status = .error
            self.lastUpdated = "Error: \(error.localizedDescription)"
            throw Errors.networkError(reason: error.localizedDescription)
        }
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
