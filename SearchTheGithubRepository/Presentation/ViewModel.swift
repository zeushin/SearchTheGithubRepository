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
  
  init() {
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
        case .searchButtonTapped(let query):
          return self.performSearch(query: query)
        }
      }
      .receive(on: RunLoop.main)
      .sink { [weak self] newState in
        self?.state = newState
      }
      .store(in: &cancellables)
  }
  
  func loadRecentSearches() {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
      self?.state.recentSearches = [
        Keyword(text: "1", updated: .now - 1),
        Keyword(text: "2", updated: .now - 2),
        Keyword(text: "3", updated: .now - 3),
        Keyword(text: "4", updated: .now - 4),
      ]
    }
  }
  
  func performSearch(query: String) -> AnyPublisher<State, Never> {
    Just(query)
      .map { query in
        return self.saveRecentSearch(query: query)
      }.eraseToAnyPublisher()
  }
  
  func saveRecentSearch(query: String) -> State {
    // TODO: user defaults 에 저장후, 저장된 내용을 recent searches에 저장
    var newState = state
    newState.recentSearches.append(Keyword(text: query, updated: .now))
    return newState
  }
}
