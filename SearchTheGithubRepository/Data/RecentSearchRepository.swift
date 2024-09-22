//
//  RecentSearchRepository.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation

struct RecentSearchUserDefaultsRepository: RecentSearchRepository {

  func getRecentSearches() -> [Keyword] {
    guard let data = UserDefaults.standard.data(forKey: "RecentSearches"),
          let recentSearches = try? JSONDecoder().decode([KeywordDTO].self, from: data)
    else { return [] }
    return recentSearches.map {
      Keyword(text: $0.query, updated: $0.updated)
    }
  }
  
  func setRecentSearches(keywords: [Keyword]) {
    guard let encodedData = try? JSONEncoder()
      .encode(keywords.map { KeywordDTO(query: $0.text, updated: $0.updated) })
    else { return }
    UserDefaults.standard.set(encodedData, forKey: "RecentSearches")
  }
  
}
