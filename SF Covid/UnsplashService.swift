import Foundation

final class UnsplashController: ObservableObject {
    var APIKey: String
    let baseURL = URL(string: "https://api.unsplash.com")!
    private let decoder: JSONDecoder
    
    enum Errors: Error {
        case invalidQuery
    }
    
    init(_ key: String) {
        self.APIKey = "Client-ID \(key)"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }
    
    func search(_ query: String) async throws -> [URL] {
        guard let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw Errors.invalidQuery
        }
        let url = baseURL.appendingPathComponent("search/photos?query=\(queryString)")
        var request = URLRequest(url: url)
        request.setValue(APIKey, forHTTPHeaderField: "Authorization")
        let res = try await URLSession.shared.data(for: request, delegate: nil)
        let response = try decoder.decode([UnsplashResult].self, from: res.0)
        let urls = response.compactMap { result -> URL? in
            guard let urlString = result.urls["regular"] else { return nil }
            return URL(string: urlString)
        }
        return urls
    }
}


struct UnsplashResult: Codable {
    let id: String
    let createdAt, updatedAt: Date
    let width, height: Int
    let color, blurHash: String
    let urls: [String : String]

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width, height, color
        case blurHash = "blur_hash"
        case urls
    }
}
