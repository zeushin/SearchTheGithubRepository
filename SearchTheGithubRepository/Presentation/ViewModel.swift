//
//  ViewModel.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation
import Combine

final class ViewModel {
  
  enum CellType: String {
    case recentKeywordCell = "RecentKeywordCell"
    case removeAllCell = "RemoveAllCell"
    case suggestionCell = "SuggestionCell"
  }
  
  enum Action {
    case searchButtonTapped(String)
    case deleteButtonTapped(String)
    case removeAllButtonTapped
    case searchTextChanged(String?, Bool)
  }
  
  struct State {
    var searchResults: [Keyword] = []
    var recentSearches: [Keyword] = []
    var suggestions: [Keyword] = []
    var isActive: Bool = false
    
    var numberOfRows: Int {
      isActive ? suggestions.count : recentSearches.count + 1
    }
    
    func cellIdentifier(for indexPath: IndexPath) -> String {
      func cellIdentifier(for indexPath: IndexPath) -> CellType {
        if isActive {
          return .suggestionCell
        } else {
          return indexPath.row < recentSearches.count ? .recentKeywordCell : .removeAllCell
        }
      }
      return cellIdentifier(for: indexPath).rawValue
    }
    
    func cellKeyword(for indexPath: IndexPath) -> Keyword? {
      if isActive {
        return suggestions[indexPath.row]
      } else if indexPath.row < recentSearches.count {
        return recentSearches[indexPath.row]
      } else {
        return nil
      }
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
    case .searchTextChanged(let text, let isActive):
      updateSuggestions(for: text, isActive)
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
  
  func updateSuggestions(for text: String?, _ isActive: Bool) {
    state.isActive = isActive
    guard let text else {
      state.suggestions = []
      return
    }
    state.suggestions = state.recentSearches.filter { keyword in
      let normalizedKeyword = keyword.text.lowercased().trimmingCharacters(in: .whitespaces)
      let normalizedText = text.lowercased().trimmingCharacters(in: .whitespaces)
      return normalizedKeyword.contains(normalizedText)
    }
  }
  
}
