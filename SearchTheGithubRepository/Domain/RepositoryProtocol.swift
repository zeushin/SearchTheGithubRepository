//
//  RepositoryProtocol.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation

protocol RecentSearchRepository {
  func getRecentSearches() -> [Keyword]
  func setRecentSearches(keywords: [Keyword])
}

protocol SearchRepository {
  func getSearch(query: String, page: Int) async -> [SearchResultItem]
}
