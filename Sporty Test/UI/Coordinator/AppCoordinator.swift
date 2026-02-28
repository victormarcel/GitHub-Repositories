import GitHubAPI
import MockLiveServer
import UIKit

@MainActor
final class AppCoordinator {
    
    // MARK: - PRIVATE METHODS
    
    private let window: UIWindow
    private let factory: SportyFactoryProtocol = SportyFactory()
    
    private var navigationViewController: UINavigationController? {
        return window.rootViewController as? UINavigationController
    }
    
    // MARK: - INITIALIZERES
    
    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - INTERNAL METHODS
    
    func start() {
        let repositoriesViewController = factory.makeRepositoriesViewController(delegate: self)
        window.rootViewController = UINavigationController(rootViewController: repositoriesViewController)
        window.makeKeyAndVisible()
    }
    
    func navigateToRepositoryScreen(repository: GitHubMinimalRepository) {
        let viewController = factory.makeRepositoryViewController(repository: repository)
        push(viewController)
    }
    
    // MARK: - PRIVATE METHODS
    
    private func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationViewController?.pushViewController(viewController, animated: animated)
    }
}
