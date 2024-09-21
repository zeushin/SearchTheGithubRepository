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
  private var cancellables = Set<AnyCancellable>()
  private let actionSubject = PassthroughSubject<Action, Never>()
  private let useCase: SearchUseCase
  
  init(searchUseCase: SearchUseCase) {
    useCase = searchUseCase
    bindActions()
    loadRecentSearches()
  }
  
  func send(_ action: Action) {
    actionSubject.send(action)
  }
}

private extension ViewModel {
  
  func bindActions() {
    actionSubject
      .flatMap { [weak self] action -> AnyPublisher<State, Never> in
        guard let self = self else { return Just(State()).eraseToAnyPublisher() }
        switch action {
        case .searchButtonTapped(let text):
          return performSearch(text: text)
        case .deleteButtonTapped(let text):
          return deleteRecentSearch(text: text)
        case .removeAllButtonTapped:
          return removeAllRecentSearches()
        }
      }
      .receive(on: RunLoop.main)
      .sink { [weak self] newState in
        self?.state = newState
      }
      .store(in: &cancellables)
  }
  
  func loadRecentSearches() {
    state.recentSearches = useCase.recentSearches
  }
  
  func performSearch(text: String) -> AnyPublisher<State, Never> {
    Just(text)
      .map { text in
        return self.saveRecentSearch(text: text)
      }.eraseToAnyPublisher()
  }
  
  func saveRecentSearch(text: String) -> State {
    useCase.saveSearchText(text)
    var newState = state
    newState.recentSearches = useCase.recentSearches
    return newState
  }
  
  func deleteRecentSearch(text: String) -> AnyPublisher<State, Never> {
    useCase.deleteSearchText(text)
    var newState = state
    newState.recentSearches = useCase.recentSearches
    return Just(newState).eraseToAnyPublisher()
  }
  
  func removeAllRecentSearches() -> AnyPublisher<State, Never> {
    useCase.deleteAllRecentSearches()
    var newState = state
    newState.recentSearches = useCase.recentSearches
    return Just(newState).eraseToAnyPublisher()
  }
}
