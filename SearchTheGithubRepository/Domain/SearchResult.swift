//
//  SearchResult.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/22/24.
//

import Foundation

struct SearchResult {
  let totalCount: Int
  let items: [SearchResultItem]
  var hasMorePages: Bool {
    totalCount > items.count
  }
}

struct SearchResultItem {
  let thumbnail: URL?
  let title: String
  let desscription: String
  let repositoryURL: URL?
}
