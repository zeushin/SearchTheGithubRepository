//
//  ViewModel.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation
import UIKit

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
    case loadNextPage
  }
  
  struct State {
    fileprivate var searchedText: String = ""
    fileprivate var searchResult: SearchResult?
    fileprivate var recentSearches: [Keyword] = []
    fileprivate var suggestions: [Keyword] = []
    fileprivate var currentPage: Int = 1
    fileprivate(set) var isLoading: Bool = false
    fileprivate var hasMorePages: Bool = true
    fileprivate var searchState: SearchState = .idle
    
    var numberOfRows: Int {
      switch searchState {
      case .idle:
        return recentSearches.count + 1
      case .typing:
        return suggestions.count
      case .result:
        return searchResult?.items.count ?? 0
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
            let searchResults = searchResult?.items,
            searchResults.count > indexPath.row else {
        return nil
      }
      return searchResults[indexPath.row]
    }
    
    var sectionHeader: (title: String, height: CGFloat, textColor: UIColor?) {
      switch searchState {
      case .idle:
        return (
          "최근 검색",
          28.0,
          UIColor { $0.userInterfaceStyle == .dark ? .lightText : .darkText }
        )
      case .typing:
        return ("", 0, nil)
      case .result:
        return (
          "\(searchResult?.totalCount.decimal ?? "0")개 저장소",
          28.0,
          UIColor { $0.userInterfaceStyle == .dark ? .lightGray : .darkGray }
        )
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
      resetPagination()
      await requestSearch(text: text)
    case .deleteButtonTapped(let text):
      deleteRecentSearch(text: text)
    case .removeAllButtonTapped:
      removeAllRecentSearches()
    case .searchTextChanged(let text):
      updateSearchState(with: text)
      updateSuggestions(for: text)
    case .loadNextPage:
      await loadNextPage()
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
      state.searchResult = nil
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
    state.isLoading = true
    let result = await useCase.requestSearch(text, page: state.currentPage)
    state.isLoading = false
    
    if state.currentPage == 1 {
      state.searchResult = result
    } else {
      state.searchResult = SearchResult(
        totalCount: result.totalCount,
        items: (state.searchResult?.items ?? []) + result.items
      )
    }
    state.hasMorePages = state.searchResult?.hasMorePages ?? false
  }
  
  func loadNextPage() async {
    guard state.searchState == .result &&
            state.isLoading == false &&
            state.hasMorePages else { return }
    state.currentPage += 1
    await requestSearch(text: state.searchedText)
  }
  
  func resetPagination() {
    state.currentPage = 1
    state.hasMorePages = true
  }
  
}

extension Int {
  var decimal: String? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale.current
    return formatter.string(from: NSNumber(value: self))
  }
}
