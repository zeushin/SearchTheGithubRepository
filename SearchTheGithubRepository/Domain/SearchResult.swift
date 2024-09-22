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
}

struct SearchResultItem {
  let thumbnail: URL?
  let title: String
  let desscription: String
}
