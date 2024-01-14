// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine


@available(iOS 13.0, *)
public struct HTTPClient {
   public enum HTTPError: Error {
        case statusCode(HTTPURLResponse)
        case requestFailed(Error)
        case invalidResponse
    }
    
    public init() {}

   public func request<T: Decodable>(_ url: URL, decodingType: T.Type) -> AnyPublisher<T, HTTPError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw HTTPError.invalidResponse
                }

                guard 200..<300 ~= httpResponse.statusCode else {
                    throw HTTPError.statusCode(httpResponse)
                }

                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let httpError = error as? HTTPError {
                    return httpError
                } else {
                    return HTTPError.requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
