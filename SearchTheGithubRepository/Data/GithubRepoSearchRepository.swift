//
//  GithubRepoSearchRepository.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/22/24.
//

import Foundation
import Moya

struct GithubRepoSearchRepository: SearchRepository {
  
  private let provider: MoyaProvider<GitHubAPI>
  
  init() {
      self.provider = MoyaProvider()
  }
  
  func getSearch(query: String, page: Int) async -> [SearchResultItem] {
    do {
      return try await provider.requestAsync(
        .getRepositories(query: query, page: page),
        for: GitHubRepoDTO.self
      ).items.map {
        SearchResultItem(
          thumbnail: URL(string: $0.owner.avatar_url ?? ""),
          title: $0.name,
          desscription: $0.owner.login
        )
      }
    } catch {
      return []
    }
  }
}
