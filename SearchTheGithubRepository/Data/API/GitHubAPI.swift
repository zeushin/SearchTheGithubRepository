//
//  GitHubAPI.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/22/24.
//

import Foundation
import Moya

enum GitHubAPI: TargetType {
  
  case getRepositories(query: String, page: Int)
  
  var baseURL: URL {
    URL(string: "https://api.github.com")!
  }
  
  var path: String {
    switch self {
    case .getRepositories:
      return "/search/repositories"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .getRepositories:
      return .get
    }
  }
  
  var task: Task {
    switch self {
    case .getRepositories(let query, let page):
      return .requestParameters(
        parameters: ["q": query, "page": page],
        encoding: URLEncoding.default
      )
    }
  }
  
  var headers: [String: String]? {
    nil
  }
  
}
