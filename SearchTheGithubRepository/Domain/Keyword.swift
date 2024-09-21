//
//  Keyword.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import Foundation

struct Keyword: Equatable {
  let text: String
  let updated: Date
}

struct KeywordDTO: Codable {
  let query: String
  let updated: Date
}
