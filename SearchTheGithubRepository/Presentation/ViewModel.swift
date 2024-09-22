//
//  ViewModel.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation
import Combine

final class ViewModel {
  
  enum Action {
    case searchButtonTapped(String)
    case deleteButtonTapped(String)
    case removeAllButtonTapped
  }
  
  struct State {
    var searchText: String = ""
    var searchResults: [Keyword] = []
    var recentSearches: [Keyword] = []
    var suggestions: [Keyword] = []
    
    var numberOfRows: Int {
      recentSearches.count + 1
    }
    
    func cellIdentifier(for indexPath: IndexPath) -> String {
      if indexPath.row < recentSearches.count {
        return "RecentKeywordCell"
      } else {
        return "RemoveAllCell"
      }
    }
    
    func cellKeyword(for indexPath: IndexPath) -> Keyword? {
      guard indexPath.row < recentSearches.count else { return nil }
      return recentSearches[indexPath.row]
    }
  }
  
  @Published private(set) var state = State()
  private let useCase: SearchUseCase
  
  init(searchUseCase: SearchUseCase) {
    useCase = searchUseCase
    loadRecentSearches()
  }
  
  func send(_ action: Action) async {
    switch action {
    case .searchButtonTapped(let text):
      saveRecentSearch(text: text)
    case .deleteButtonTapped(let text):
      deleteRecentSearch(text: text)
    case .removeAllButtonTapped:
      removeAllRecentSearches()
    }
  }
}

private extension ViewModel {
  
  func loadRecentSearches() {
    state.recentSearches = useCase.recentSearches
  }
  
  func saveRecentSearch(text: String) {
    useCase.saveSearchText(text)
    state.recentSearches = useCase.recentSearches
  }
  
  func deleteRecentSearch(text: String) {
    useCase.deleteSearchText(text)
    state.recentSearches = useCase.recentSearches
  }
  
  func removeAllRecentSearches() {
    useCase.deleteAllRecentSearches()
    state.recentSearches = useCase.recentSearches
  }
  
}
