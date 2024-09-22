//
//  GithubRepoSearchRepository.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/22/24.
//

import Foundation

struct GithubRepoSearchRepository: SearchRepository {
  func getSearch(query: String) async -> [SearchResultItem] {
    return [ // fix dummy
      SearchResultItem(
        thumbnail: URL(string: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/swift/swift.png?size=48")!,
        title: "hoho",
        desscription: "helllllow"
      )
    ]
  }
}
