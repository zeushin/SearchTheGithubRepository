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
    searchController.searchBar.delegate = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "저장소 검색"
    (searchController.searchBar.value(forKey: "searchField") as? UITextField)?
      .tintColor = .purple
    return searchController
  }()
  
  @IBOutlet private weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
  }
  
}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    print(":::::", searchController.isActive)
  }
  
}

extension ViewController: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchController.searchBar.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchController.searchBar.setShowsCancelButton(false, animated: true)
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var idid = ""
    switch indexPath.row {
    case 0:
      idid = "AutoCompletionCell"
    case 1:
      idid = "RecentKeywordCell"
    case 2:
      idid = "RemoveAllCell"
    default:
      idid = "AutoCompletionCell"
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: idid, for: indexPath)
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "최근 검색" // TODO: font변경
  }
  
}
