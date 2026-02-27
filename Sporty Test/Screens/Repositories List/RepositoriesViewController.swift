import Combine
import GitHubAPI
import MockLiveServer
import SwiftUI
import UIKit

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
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.className)
    }
    
    private func handleStateChange(_ state: RepositoriesViewModel.State) {
        switch state {
        case .loading:
            handleLoadingState(true)
        case .success:
            handleLoadingState(false)
            tableView.reloadData()
        case .error:
            handleLoadingState(false)
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
}

extension RepositoriesViewController: RepositoriesViewModelDelegate {
    
    func onStateUpdate(_ state: RepositoriesViewModel.State) {
        handleStateChange(state)
    }
}

// MARK: -  TABLE VIEW DELEGATE
extension RepositoriesViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = viewModel.repositories[indexPath.row]
        // TODO: Navigate to repository view controller through AppCoordinator
        let viewController = RepositoryViewController(
            minimalRepository: repository,
            gitHubAPI: GitHubAPI()
        )
        show(viewController, sender: self)
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
        let repository = viewModel.repositories[indexPath.row]
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.className, for: indexPath)
        
        guard let repositoryCell = tableViewCell as? RepositoryTableViewCell else {
            return tableViewCell
        }

        repositoryCell.setup(by: repository)
        return repositoryCell
    }
}
