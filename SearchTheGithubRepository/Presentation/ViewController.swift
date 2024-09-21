//
//  ViewController.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import UIKit

class ViewController: UIViewController {
  
  private lazy var searchController: UISearchController = {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "저장소 검색"
    searchController.searchBar.showsCancelButton = true
    return searchController
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
  }

}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    
  }
  
}

