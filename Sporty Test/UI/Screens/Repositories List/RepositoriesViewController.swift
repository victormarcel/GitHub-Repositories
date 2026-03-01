import Combine
import GitHubAPI
import MockLiveServer
import SwiftUI
import UIKit

@MainActor
protocol RepositoriesViewControllerDelegate: AnyObject {
    
    func repositoriesViewController(
        viewController: RepositoriesViewController,
        didTapOn repository: GitHubMinimalRepository
    )
}

/// A view controller that displays a list of GitHub repositories for the "swiftlang" organization.
final class RepositoriesViewController: UITableViewController {
    
    // MARK: - CONSTANTS
    
    private enum Constants {
        
        enum ViewController {
            static let title = "Repositories"
        }
        
        enum TableView {
            static let numberOfSections = 1
        }
        
        enum FeedbackView {
            static let errorStateData = FeedbackViewData(
                imageName: "wifi.slash",
                title: "Couldn't Load Repositories",
                description: "Something went wrong on our end. Please try again later."
            )
            
            static let emptyStateData = FeedbackViewData(
                imageName: "tray",
                title: "No Repositories Found",
                description: "We couldn't find any repositories matching your search. Try different keywords."
            )
        }
    }
    
    // MARK: - PRIVATE PROPERTIES
    
    private let viewModel: RepositoriesViewModel
    
    // MARK: - INTERNAL PROPERTIES
    
    weak var delegate: RepositoriesViewControllerDelegate?
    
    // MARK: - INITIALIZERS
    
    init(viewModel: RepositoriesViewModel) {
        self.viewModel = viewModel
        
        super.init(style: .insetGrouped)
        
        viewModel.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        viewModel.onViewDidLoad()
    }
    
    // MARK: - UI
    
    private lazy var searchView: SearchView = {
        let searchView = SearchView()
        searchView.translatesAutoresizingMaskIntoConstraints = false
        searchView.onSearchTapped = viewModel.onSearchTap
        searchView.setText(RepositoriesViewModel.Constants.defaultOrganizationName)
        return searchView
    }()
    
    private lazy var feedbackView: FeedbackView = {
        let view = FeedbackView()
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }()
    
    // MARK: - PRIVATE METHODS
    
    private func setup() {
        setupLayout()
        setupLayoutConstraints()
    }
    
    private func setupLayout() {
        title = Constants.ViewController.title
        setupTableView()
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            searchInputView.topAnchor.constraint(equalTo: tableView.topAnchor),
            searchInputView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            searchInputView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            searchInputView.widthAnchor.constraint(equalTo: tableView.widthAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.className)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.tableHeaderView = searchInputView
    }
    
    @objc
    private func didPullToRefresh() {
        viewModel.didPullToRefresh()
    }
    
    private func handleStateChange(_ state: RepositoriesScreenState) {
        switch state {
        case .loading:
            handleLoadingState(true)
        case .success:
            handleSuccessState()
        case .error:
            handleErrorState()
        default:
            return
        }
    }
    
    private func handleLoadingState(_ isLoading: Bool) {
        tableView.reloadData()
        tableView.backgroundView = isLoading ? buildAnimationBackgroundView() : nil
        tableView.isScrollEnabled = false
    }
    
    private func buildAnimationBackgroundView() -> UIView {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        return spinner
    }
    
    private func handleSuccessState() {
        handleLoadingState(false)
        tableView.refreshControl?.endRefreshing()
        tableView.isScrollEnabled = true
        tableView.reloadData()
    }
    
    private func handleErrorState() {
        handleLoadingState(false)
        tableView.isScrollEnabled = false
        setupErrorFeedback()
    }
    
    private func setupErrorFeedback() {
        switch viewModel.state {
        case .error(let error) where error == .notFound:
            feedbackView.setup(data: Constants.FeedbackView.emptyStateData)
        case .error:
            feedbackView.setup(data: Constants.FeedbackView.errorStateData)
        default:
            tableView.backgroundView = nil
            return
        }
        
        tableView.backgroundView = feedbackView
    }
}

extension RepositoriesViewController: RepositoriesViewModelDelegate {
    func onPullToRefreshError() {
        tableView.refreshControl?.endRefreshing()
    }
    
    
    func onStateUpdate(_ state: RepositoriesScreenState) {
        handleStateChange(state)
    }
}

// MARK: -  TABLE VIEW DELEGATE
extension RepositoriesViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let repository = viewModel.repositories[safe: indexPath.row] else {
            return
        }
        
        delegate?.repositoriesViewController(viewController: self, didTapOn: repository)
    }
}

// MARK: - TABLE VIEW DATASOURCE
extension RepositoriesViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Constants.TableView.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.state == .loading ? .zero : viewModel.repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repository = viewModel.repositories[safe: indexPath.row]
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.className, for: indexPath)
        
        guard let repository, let repositoryCell = tableViewCell as? RepositoryTableViewCell else {
            return tableViewCell
        }
        
        repositoryCell.setup(by: repository)
        return repositoryCell
    }
}
