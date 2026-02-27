import GitHubAPI
import MockLiveServer
import UIKit

@MainActor
final class AppCoordinator {
    private let window: UIWindow
    private let gitHubAPI: GitHubAPI
    private let mockLiveServer: MockLiveServer

    init(window: UIWindow) {
        self.window = window
        gitHubAPI = GitHubAPI(authorisationToken: nil)
        mockLiveServer = MockLiveServer()
    }

    func start() {
        let repositoriesViewModel = RepositoriesViewModel(gitHubAPI: gitHubAPI, mockLiveServer: mockLiveServer)
        window.rootViewController = UINavigationController(
            rootViewController: RepositoriesViewController(
                viewModel: repositoriesViewModel
            )
        )
        window.makeKeyAndVisible()
    }
}
