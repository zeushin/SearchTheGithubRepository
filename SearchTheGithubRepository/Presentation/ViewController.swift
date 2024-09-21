//
//  ViewController.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import UIKit
import Combine

final class ViewController: UIViewController {
  
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
  private var viewModel = ViewModel()
  private var cancellables = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    bindViewModel()
    setupSearchBar()
    setupSearchBarObserver()
  }
  
}

private extension ViewController {
  func bindViewModel() {
    viewModel.$state
      .map { $0.recentSearches }
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        self?.tableView.reloadData()
      }
      .store(in: &cancellables)
  }
  
  func setupSearchBarObserver() {
    searchController.searchBar
      .publisher(for: \.text)
      .compactMap { $0 }
      .sink { [weak self] text in
        print(text) // TODO: send to view model
      }
      .store(in: &cancellables)
  }
  
  func setupSearchBar() {
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
//    var idid = ""
//    switch indexPath.row {
//    case 0:
//      idid = "AutoCompletionCell"
//    case 1:
//      idid = "RecentKeywordCell"
//    case 2:
//      idid = "RemoveAllCell"
//    default:
//      idid = "AutoCompletionCell"
//    }
    let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.state.cellIdentifier, for: indexPath)
    (cell as? RecentKeywordCell)?.keywordLabel.text = viewModel.state.cellKeyword(for: indexPath).text
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.state.numberOfRows
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "최근 검색" // TODO: font변경
  }
  
}
