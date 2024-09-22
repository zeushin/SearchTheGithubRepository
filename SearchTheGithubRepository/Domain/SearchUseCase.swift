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
  func requestSearch(_ text: String, page: Int) async -> [SearchResultItem]
}

struct SearchUseCaseImpl: SearchUseCase {
  
  let recentSearchRepository: RecentSearchRepository
  let searchRepository: SearchRepository
  
  init(
    recentSearchRepository: RecentSearchRepository,
    searchRepository: SearchRepository
  ) {
    self.recentSearchRepository = recentSearchRepository
    self.searchRepository = searchRepository
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
  
  func requestSearch(_ text: String, page: Int) async -> [SearchResultItem] {
    await searchRepository.getSearch(query: text, page: page)
  }
  
}

private extension SearchUseCaseImpl {
  
  var recentSearchesQueue: [Keyword] {
    recentSearchRepository.getRecentSearches()
  }
  
  func syncRecentSearches(keywords: [Keyword]) {
    recentSearchRepository.setRecentSearches(keywords: keywords)
  }
  
}
