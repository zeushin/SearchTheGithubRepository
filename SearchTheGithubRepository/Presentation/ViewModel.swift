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
  }
  
  struct State {
    var searchText: String = ""
    var searchResults: [Keyword] = []
    var recentSearches: [Keyword] = []
    var suggestions: [Keyword] = []
    
    var numberOfRows: Int {
      recentSearches.count
    }
    
    var cellIdentifier: String {
      "RecentKeywordCell"
    }
    
    func cellKeyword(for indexPath: IndexPath) -> Keyword {
      recentSearches[indexPath.row]
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
          return self.performSearch(text: text)
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
}
