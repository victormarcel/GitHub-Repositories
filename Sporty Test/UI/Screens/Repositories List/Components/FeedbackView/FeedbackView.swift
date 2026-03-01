//
//  FeedbackView.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import UIKit

final class FeedbackView: UIView {

    // MARK: - CONSTANTS
    
    private enum Constants {
        
        enum MainStackView {
            static let spacing: CGFloat = 16
            static let horizontalMargin: CGFloat = 32
        }
        
        enum ImageView {
            static let size: CGFloat = 64
        }
        
        enum LabelsStackView {
            static let spacing: CGFloat = 8
        }
        
        enum TitleLabel {
            static let fontSize: CGFloat = 18
        }
        
        enum DescriptionLabel {
            static let fontSize: CGFloat = 14
        }
    }
    
    // MARK: - UI
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, labelsStackView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.MainStackView.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.LabelsStackView.spacing
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.TitleLabel.fontSize, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = .zero
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.DescriptionLabel.fontSize, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = .zero
        return label
    }()

    // MARK: - INITIALIZERS

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - INTERNAL METHODS

    func setup(data: FeedbackViewData) {
        imageView.image = UIImage(systemName: data.imageName)
        titleLabel.text = data.title
        descriptionLabel.text = data.description
    }

    // MARK: - PRIVATE METHODS
    
    private func setup() {
        setupLayoutConstraints()
    }
    
    private func setupLayoutConstraints() {
        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.ImageView.size),
            imageView.heightAnchor.constraint(equalToConstant: Constants.ImageView.size),

            mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.MainStackView.horizontalMargin),
            mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.MainStackView.horizontalMargin),
        ])
    }
}
