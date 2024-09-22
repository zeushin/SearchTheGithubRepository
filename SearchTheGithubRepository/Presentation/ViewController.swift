//
//  ViewController.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import UIKit
import Combine
import Kingfisher

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
  private var viewModel = ViewModel(
    searchUseCase: SearchUseCaseImpl(
      recentSearchRepository: RecentSearchUserDefaultsRepository(),
      searchRepository: GithubRepoSearchRepository()
    )
  )
  private var cancellables = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
    setupSearchBar()
  }
  
}

private extension ViewController {
  func bindViewModel() {
    viewModel.$state
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        self?.tableView.reloadData()
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
    Task {
      await viewModel.send(
        .searchTextChanged(searchController.searchBar.text, searchController.isActive)
      )
    }
  }
  
}

extension ViewController: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchController.searchBar.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchController.searchBar.setShowsCancelButton(false, animated: true)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let text = searchBar.text else { return }
    Task {
      await viewModel.send(.searchButtonTapped(text))
    }
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier: String = viewModel.state.cellIdentifier(for: indexPath)
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    
    switch ViewModel.CellType(rawValue: identifier) {
    case .recentKeywordCell:
      if let text = viewModel.state.cellKeyword(for: indexPath)?.text {
        (cell as? RecentKeywordCell)?.keywordLabel.text = text
        (cell as? RecentKeywordCell)?.onDelete = { [weak self] in
          Task {
            await self?.viewModel.send(.deleteButtonTapped(text))
          }
        }
      }
    case .suggestionCell:
      if let keyword = viewModel.state.cellKeyword(for: indexPath) {
        cell.textLabel?.text = keyword.text
        cell.detailTextLabel?.text = keyword.displayDate
      }
    case .searchResultCell:
      if let searchResult = viewModel.state.cellSearchReuslt(for: indexPath) {
        (cell as? SearchResultCell)?.thumbnailView.kf.setImage(with: searchResult.thumbnail)
        (cell as? SearchResultCell)?.titleLabel.text = searchResult.title
        (cell as? SearchResultCell)?.descriptionLabel.text = searchResult.desscription
      }
    case .removeAllCell, .none:
      break
    }
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let identifier = viewModel.state.cellIdentifier(for: indexPath)
    switch ViewModel.CellType(rawValue: identifier) {
    case .removeAllCell:
      Task {
        await viewModel.send(.removeAllButtonTapped)
      }
    case .recentKeywordCell, .suggestionCell:
      if let keyword = viewModel.state.cellKeyword(for: indexPath) {
        searchController.isActive = true
        searchController.searchBar.text = keyword.text
        searchBarSearchButtonClicked(searchController.searchBar)
      }
    case .searchResultCell:
      // TODO: web view
      break
    case .none:
      break
    }
  }
  
}
