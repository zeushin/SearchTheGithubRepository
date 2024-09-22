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
  var displayDate: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM. dd."
    return dateFormatter.string(from: updated)
  }
}

struct SearchResultItem {
  let thumbnail: URL?
  let title: String
  let desscription: String
}
