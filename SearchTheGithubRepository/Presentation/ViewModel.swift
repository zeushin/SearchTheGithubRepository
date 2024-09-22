//
//  ViewModel.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation

final class ViewModel {
  
  enum CellType: String {
    case recentKeywordCell = "RecentKeywordCell"
    case removeAllCell = "RemoveAllCell"
    case suggestionCell = "SuggestionCell"
    case searchResultCell = "SearchResultCell"
  }
  
  enum SearchState {
    case idle
    case typing
    case result
  }
  
  enum Action {
    case searchButtonTapped(String)
    case deleteButtonTapped(String)
    case removeAllButtonTapped
    case searchTextChanged(String?)
  }
  
  struct State {
    fileprivate var searchedText: String = ""
    fileprivate var searchResults: [SearchResultItem] = []
    fileprivate var recentSearches: [Keyword] = []
    fileprivate var suggestions: [Keyword] = []
    fileprivate var searchState: SearchState = .idle
    
    var numberOfRows: Int {
      switch searchState {
      case .idle:
        return recentSearches.count + 1
      case .typing:
        return suggestions.count
      case .result:
        return searchResults.count
      }
    }
    
    func cellIdentifier(for indexPath: IndexPath) -> String {
      func cellIdentifier(for indexPath: IndexPath) -> CellType {
        switch searchState {
        case .idle:
          return indexPath.row < recentSearches.count ? .recentKeywordCell : .removeAllCell
        case .typing:
          return .suggestionCell
        case .result:
          return .searchResultCell
        }
      }
      return cellIdentifier(for: indexPath).rawValue
    }
    
    func cellKeyword(for indexPath: IndexPath) -> Keyword? {
      switch searchState {
      case .idle:
        return recentSearches[indexPath.row]
      case .typing:
        return suggestions[indexPath.row]
      case .result:
        return nil
      }
    }
    
    func cellSearchReuslt(for indexPath: IndexPath) -> SearchResultItem? {
      guard case .result = searchState,
            searchResults.count > indexPath.row else {
        return nil
      }
      return searchResults[indexPath.row]
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
      await requestSearch(text: text)
    case .deleteButtonTapped(let text):
      deleteRecentSearch(text: text)
    case .removeAllButtonTapped:
      removeAllRecentSearches()
    case .searchTextChanged(let text):
      updateSearchState(with: text)
      updateSuggestions(for: text)
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
    state.searchedText = text
    state.searchState = .result
  }
  
  func deleteRecentSearch(text: String) {
    useCase.deleteSearchText(text)
    state.recentSearches = useCase.recentSearches
  }
  
  func removeAllRecentSearches() {
    useCase.deleteAllRecentSearches()
    state.recentSearches = useCase.recentSearches
  }
  
  func updateSearchState(with text: String?) {
    if state.searchedText != text {
      state.searchedText = ""
      state.searchResults = []
    }
    
    guard state.searchedText.isEmpty else { return }

    if (text ?? "").isEmpty {
      state.searchState = .idle
    } else {
      state.searchState = .typing
    }
  }
  
  func updateSuggestions(for text: String?) {
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
  
  func requestSearch(text: String) async {
    state.searchResults = await useCase.requestSearch(text, page: 0)
  }
  
}
