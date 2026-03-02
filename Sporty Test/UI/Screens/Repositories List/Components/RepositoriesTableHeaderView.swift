//
//  RepositoriesTableHeaderView.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import UIKit

final class RepositoriesTableHeaderView: UIView {

    // MARK: - CONSTANTS

    private enum Constants {

        enum StackView {
            static let spacing: CGFloat = 8
            static let horizontalMargin: CGFloat = 16
        }

        enum KeyButton {
            static let imageName = "key.fill"
            static let size: CGFloat = 35
            static let cornerRadius: CGFloat = KeyButton.size/2
            static let iconPointSize: CGFloat = 18
        }
    }

    // MARK: - INTERNAL PROPERTIES

    var onKeyTapped: (() -> Void)?

    // MARK: - UI

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchView, keyButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.StackView.spacing
        return stack
    }()

    let searchView: SearchView = {
        let view = SearchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var keyButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: Constants.KeyButton.imageName,
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: Constants.KeyButton.iconPointSize, weight: .medium))
        config.cornerStyle = .fixed
        config.background.cornerRadius = Constants.KeyButton.cornerRadius
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(didTapKey), for: .touchUpInside)
        return button
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

    // MARK: - PRIVATE METHODS

    private func setup() {
        addSubview(stackView)

        NSLayoutConstraint.activate([
            keyButton.widthAnchor.constraint(equalToConstant: Constants.KeyButton.size),
            keyButton.heightAnchor.constraint(equalToConstant: Constants.KeyButton.size),

            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.StackView.horizontalMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.StackView.horizontalMargin),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func didTapKey() {
        onKeyTapped?()
    }
}
