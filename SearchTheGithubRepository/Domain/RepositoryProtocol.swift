//
//  RepositoryProtocol.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation

protocol RecentSearchRepository {
  func getRecentSearches() -> [KeywordDTO]
  func setRecentSearches(keywords: [KeywordDTO])
}

protocol SearchRepository {
  
}
