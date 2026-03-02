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
    
    func repositoriesViewControllerDidTapOnKeyButton(
        viewController: RepositoriesViewController
    )
}

/// A view controller that displays a list of GitHub repositories for the "swiftlang" organization.
final class RepositoriesViewController: UITableViewController {
    
    // MARK: - PRIVATE PROPERTIES
    
    private let viewModel: RepositoriesViewModel
    
    private lazy var onSearchTap: (String) -> Void = { [weak self] text in
        self?.viewModel.onSearchTap(text)
    }
    
    private lazy var onKeyButtonTap: () -> Void = { [weak self] in
        guard let self else { return }
        self.delegate?.repositoriesViewControllerDidTapOnKeyButton(viewController: self)
    }
    
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
    
    private lazy var tableHeaderView: RepositoriesTableHeaderView = {
        let headerView = RepositoriesTableHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.searchView.onSearchTapped = onSearchTap
        headerView.onKeyTapped = onKeyButtonTap
        headerView.searchView.setText(RepositoriesViewModel.Constants.defaultOrganizationName)
        return headerView
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
            tableHeaderView.topAnchor.constraint(equalTo: tableView.topAnchor),
            tableHeaderView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            tableHeaderView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            tableHeaderView.widthAnchor.constraint(equalTo: tableView.widthAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.className)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.tableHeaderView = tableHeaderView
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
        case .error(let error) where error == .unauthorized:
            feedbackView.setup(data: Constants.FeedbackView.unauthorizedStateData)
        case .error:
            feedbackView.setup(data: Constants.FeedbackView.errorStateData)
        default:
            tableView.backgroundView = nil
            return
        }
        
        tableView.backgroundView = feedbackView
    }
    
    private func hideSearchKeyboard() {
        tableHeaderView.searchView.textField.resignFirstResponder()
    }
}

extension RepositoriesViewController: RepositoriesViewModelDelegate {
    
    func onRepositoryStarCountChange(_ repository: GitHubMinimalRepository, newStarCount: Int) {
        Task { @MainActor in
            guard let index = self.viewModel.repositories.firstIndex(where: { $0.id == repository.id }),
                  let cell = self.tableView.cellForRow(at: .init(row: index, section: .zero)) as? RepositoryTableViewCell else {
                return
            }
            
            cell.updateStarCount(newStarCount)
        }
    }
    
    func onPullToRefreshError() {
        tableView.refreshControl?.endRefreshing()
        showToast(Constants.pullToRefreshErrorDescription)
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
        
        hideSearchKeyboard()
        delegate?.repositoriesViewController(viewController: self, didTapOn: repository)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.didEndDisplayingCell(at: indexPath.row)
    }
}

// MARK: - TABLE VIEW DATASOURCE
extension RepositoriesViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Constants.TableView.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repository = viewModel.repositories[safe: indexPath.row]
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.className, for: indexPath)
        
        guard let repository, let repositoryCell = tableViewCell as? RepositoryTableViewCell else {
            return tableViewCell
        }
        
        repositoryCell.setup(by: repository)
        viewModel.didSetupCell(at: indexPath.row)
        
        return repositoryCell
    }
}
