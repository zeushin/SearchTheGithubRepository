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
    
  }
  
  @Published private(set) var state = State()
  
  private var cancellables = Set<AnyCancellable>()
  private let actionSubject = PassthroughSubject<Action, Never>()
  
  init() {
    bindActions()
  }
  
  func send(_ action: Action) {
    actionSubject.send(action)
  }
}

private extension ViewModel {
  
  func bindActions() {
    
  }
}
