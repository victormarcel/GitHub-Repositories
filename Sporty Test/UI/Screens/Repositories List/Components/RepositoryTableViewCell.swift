import UIKit
import GitHubAPI

/// A cell displaying the basic information of a GitHub repository.
final class RepositoryTableViewCell: UITableViewCell {
    
    // MARK: - CONSTANTS
    
    private enum Constants {
        
        enum TitleContentStackView {
            static let spacing: CGFloat = 4
        }
        
        enum StarImageView {
            static let imageName = "star.fill"
            static let size: CGFloat = 16
        }
    }
    
    // MARK: - STATIC PROPERTIES
    
    static let className = String(describing: RepositoryTableViewCell.self)
    
    // MARK: - UI
    
    private lazy var mainContentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleContentStackView, descriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var titleContentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, starImageView, starCountLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = Constants.TitleContentStackView.spacing
        stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return stackView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        let boldDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = boldDescriptor.flatMap { UIFont(descriptor: $0, size: .zero) } ?? baseFont
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var starImageView: WrapperView<UIImageView> = {
        let imageView = UIImageView()
        let configuration = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .caption1))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Constants.StarImageView.imageName, withConfiguration: configuration)
        imageView.tintColor = .systemYellow
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let wrappedView = WrapperView(view: imageView)
        wrappedView.setDynamicHeight()
        return wrappedView
    }()
    
    private lazy var starCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = .zero
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    // MARK: - INITIALIZERS
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - INTERNAL METHODS
    
    func setup(by repository: GitHubMinimalRepository) {
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description
        starCountLabel.text = repository.stargazersCount.formatted()
    }
    
    // MARK: - PRIVATE METHODS
    
    private func setup() {
        setupLayoutConstraints()
    }
    
    private func setupLayoutConstraints() {
        contentView.addSubview(mainContentStackView)
        
        NSLayoutConstraint.activate([
            mainContentStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mainContentStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            mainContentStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            mainContentStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            starImageView.view.widthAnchor.constraint(equalToConstant: Constants.StarImageView.size),
            starImageView.view.heightAnchor.constraint(equalToConstant: Constants.StarImageView.size)
        ])
    }
}


