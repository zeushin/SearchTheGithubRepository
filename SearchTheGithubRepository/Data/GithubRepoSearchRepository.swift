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
  
  func getSearch(query: String, page: Int) async -> SearchResult {
    do {
      let dto = try await provider.requestAsync(
        .getRepositories(query: query, page: page),
        for: GitHubRepoDTO.self
      )
      return SearchResult(
        totalCount: dto.total_count,
        items: dto.items.map {
          SearchResultItem(
            thumbnail: URL(string: $0.owner.avatar_url ?? ""),
            title: $0.name,
            desscription: $0.owner.login,
            repositoryURL: URL(string: $0.html_url)
          )
        }
      )
    } catch {
      return SearchResult(totalCount: 0, items: [])
    }
  }
}
