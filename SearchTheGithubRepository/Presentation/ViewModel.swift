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
}
