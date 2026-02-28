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
            static let title = "swiftlang"
        }
        
        enum TableView {
            static let numberOfSections = 1
        }
    }
    
    // MARK: - PRIVATE PROPERTIES
    
    private let viewModel: RepositoriesViewModel
//    private let refreshControl = UIRefreshControl()
    
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
    
    // MARK: - PRIVATE METHODS
    
    private func setup() {
        setupLayout()
    }
    
    private func setupLayout() {
        title = Constants.ViewController.title
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.className)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
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
            handleLoadingState(false)
        default:
            return
        }
    }
    
    private func handleLoadingState(_ isLoading: Bool) {
        tableView.reloadData()
        tableView.backgroundView = isLoading ? buildAnimationBackgroundView() : nil
    }
    
    private func buildAnimationBackgroundView() -> UIView {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        return spinner
    }
    
    private func handleSuccessState() {
        tableView.refreshControl?.endRefreshing()
        handleLoadingState(false)
        tableView.reloadData()
    }
}

extension RepositoriesViewController: RepositoriesViewModelDelegate {
    
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
