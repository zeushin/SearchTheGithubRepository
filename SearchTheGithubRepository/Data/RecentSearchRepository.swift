//
//  RecentSearchRepository.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation

struct RecentSearchRepositoryImpl: RecentSearchRepository {

  func getRecentSearches() -> [KeywordDTO] {
    guard let data = UserDefaults.standard.data(forKey: "RecentSearches"),
          let recentSearches = try? JSONDecoder().decode([KeywordDTO].self, from: data)
    else { return [] }
    return recentSearches
  }
  
  func setRecentSearches(keywords: [KeywordDTO]) {
    guard let encodedData = try? JSONEncoder().encode(keywords) else { return }
    UserDefaults.standard.set(encodedData, forKey: "RecentSearches")
  }
  
}
