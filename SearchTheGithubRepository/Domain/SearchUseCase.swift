//
//  SearchUseCase.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation

protocol SearchUseCase {
  var recentSearches: [Keyword] { get }
  func saveSearchText(_ text: String)
  func deleteSearchText(_ text: String)
  func deleteAllRecentSearches()
}

struct SearchUseCaseImpl: SearchUseCase {
  
  let recentSearchRepository: RecentSearchRepository
  
  init(recentSearchRepository: RecentSearchRepository) {
    self.recentSearchRepository = recentSearchRepository
  }
  
  var recentSearches: [Keyword] {
    recentSearchesQueue.reversed()
  }
  
  func saveSearchText(_ text: String) {
    var searches = recentSearchesQueue
    if let index = searches.firstIndex(where: { $0.text == text }) {
      searches.remove(at: index)
    }
    searches.append(Keyword(text: text, updated: .now))
    if searches.count > 10 {
      searches.removeFirst()
    }
    syncRecentSearches(keywords: searches)
  }
  
  func deleteSearchText(_ text: String) {
    var searches = recentSearchesQueue
    if let index = searches.firstIndex(where: { $0.text == text }) {
      searches.remove(at: index)
    }
    syncRecentSearches(keywords: searches)
  }
  
  func deleteAllRecentSearches() {
    syncRecentSearches(keywords: [])
  }
  
}

private extension SearchUseCaseImpl {
  
  var recentSearchesQueue: [Keyword] {
    recentSearchRepository
      .getRecentSearches()
      .map { Keyword(text: $0.query, updated: $0.updated) }
  }
  
  func syncRecentSearches(keywords: [Keyword]) {
    recentSearchRepository.setRecentSearches(
      keywords: keywords.map { KeywordDTO(query: $0.text, updated: $0.updated) }
    )
  }
  
}
