//
//  ViewController.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import UIKit
import Combine
import Kingfisher
import SafariServices

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
        .searchTextChanged(searchController.searchBar.text)
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
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    headerView.backgroundColor = tableView.backgroundColor
    
    let headerLabel = UILabel()
    let margins = tableView.layoutMargins
    headerLabel.frame = CGRect(
      x: margins.left, 
      y: 0,
      width: tableView.frame.width - (margins.left + margins.right),
      height: 28
    )
    headerLabel.font = UIFont.boldSystemFont(ofSize: 14)
    headerLabel.text = viewModel.state.sectionHeader.title
    headerLabel.textColor = viewModel.state.sectionHeader.textColor
    
    headerView.addSubview(headerLabel)
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return viewModel.state.sectionHeader.height
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
      if let url = viewModel.state.cellSearchReuslt(for: indexPath)?.repositoryURL {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .formSheet
        present(safariVC, animated: true, completion: nil)
      }
    case .none:
      break
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let totalRows = viewModel.state.numberOfRows
    let thresholdIndex = totalRows - 5
    
    if indexPath.row == thresholdIndex {
      Task {
        await viewModel.send(.loadNextPage)
      }
    }
  }
  
}
