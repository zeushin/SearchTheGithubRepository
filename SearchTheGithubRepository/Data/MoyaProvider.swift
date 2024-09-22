//
//  MoyaProvider.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/22/24.
//

import Foundation
import Moya

extension MoyaProvider {
  func requestAsync<T: Decodable>(_ target: Target, for type: T.Type) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
      self.request(target) { result in
        switch result {
        case .success(let response):
          do {
            let decodedData = try response.map(T.self)
            continuation.resume(returning: decodedData)
          } catch {
            continuation.resume(throwing: error)
          }
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
