//
//  SearchView.swift
//  Sporty Test
//
//  Created by Victor Marcel on 28/02/26.
//

import UIKit

final class SearchView: UIView {

    // MARK: - CONSTANTS
    
    private enum Constants {
        
        enum MainStackView {
            static let spacing: CGFloat = 12
            static let verticalMargin: CGFloat = 12
            static let horizontalMargin: CGFloat = 16
        }
        
        enum InputStackView {
            static let spacing: CGFloat = 8
            static let layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            static let cornerRadius: CGFloat = 12
        }
        
        enum SearchIconImageView {
            static let imageName = "magnifyingglass"
        }
        
        enum TextField {
            static let placeholder = "Search repositories..."
        }
        
        enum ClearButton {
            static let imageName = "xmark.circle.fill"
        }
        
        enum SearchButton {
            static let title = "Search"
            static let contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            static let height: CGFloat = 44
        }
    }
    
    // MARK: - INTERNAL PROPERTIES

    var onTextChanged: ((String) -> Void)?
    var onSearchTapped: ((String) -> Void)?
    
    // MARK: - UI

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [inputStackView, searchButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.MainStackView.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var inputStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchIconImageView, textField, clearButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.InputStackView.spacing
        stack.layoutMargins = Constants.InputStackView.layoutMargins
        stack.isLayoutMarginsRelativeArrangement = true
        stack.backgroundColor = .secondarySystemBackground
        stack.layer.cornerRadius = Constants.InputStackView.cornerRadius
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: Constants.SearchIconImageView.imageName)
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.TextField.placeholder
        textField.borderStyle = .none
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.delegate = self
        textField.backgroundColor = .clear
        textField.returnKeyType = .search
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.ClearButton.imageName), for: .normal)
        button.tintColor = .secondaryLabel
        button.isHidden = true
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(didTapClear), for: .touchUpInside)
        return button
    }()

    private lazy var searchButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = Constants.SearchButton.title
        config.cornerStyle = .medium
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        let button = UIButton(configuration: config)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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

    // MARK: - INTERNAL METHODS
    
    func setText(_ text: String) {
        textField.text = text
        textDidChange()
    }
    
    // MARK: - PRIVATE METHODS

    private func setup() {
        setupLayoutConstraints()
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = .clear
    }
    
    private func setupLayoutConstraints() {
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.MainStackView.verticalMargin),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.MainStackView.horizontalMargin),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.MainStackView.horizontalMargin),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.MainStackView.verticalMargin),

            searchButton.heightAnchor.constraint(equalToConstant: Constants.SearchButton.height),
        ])
    }

    @objc private func textDidChange() {
        let text = textField.text ?? .empty
        clearButton.isHidden = text.isEmpty
        onTextChanged?(text)
    }

    @objc private func didTapClear() {
        setText(.empty)
        clearButton.isHidden = true
        onTextChanged?(.empty)
    }

    @objc private func didTapSearch() {
        textField.resignFirstResponder()
        onSearchTapped?(textField.text ?? .empty)
    }
}

// MARK: - UITEXTFIELD DELEGATE

extension SearchView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onSearchTapped?(textField.text ?? .empty)
        return true
    }
}
