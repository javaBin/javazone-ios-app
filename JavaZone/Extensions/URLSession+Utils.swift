import Foundation

enum SessionError: Error {
    case error(String)
}

extension URLSession {
    func fetchData<T: Decodable>(for urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw SessionError.error("Unable to construct URL from \(urlString)")
        }

        return try await self.fetchData(for: url)
    }

    func fetchData<T: Decodable>(for url: URL) async throws -> T {
        let fetchedData = try await self.data(from: url).0

        let result: T = try await decodeData(data: fetchedData)

        return result
    }

    func decodeData<T: Decodable>(data: Data) async throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let result = try decoder.decode(T.self, from: data)
        return result
    }
}
