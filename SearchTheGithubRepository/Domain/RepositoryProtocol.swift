//
//  RepositoryProtocol.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation

protocol RecentSearchRepositoryProtocol {
  func getRecentSearches() -> [Keyword]
  func setRecentSearches(keywords: [Keyword])
}

protocol SearchRepositoryProtocol {
  func getSearch(query: String, page: Int) async -> SearchResult
}
