import Foundation

protocol SummaryViewRepresentable: ObservableObject {
    var caseCount: String { get }
    var lastUpdated: String { get }
    var status: Status { get }
    func update(_ days: Int?) async throws
}
