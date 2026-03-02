//
//  UIViewController+Extensions.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import UIKit

extension UIViewController {

    // MARK: - CONSTANTS
    
    private enum Constants {

        static let defaultDuration: TimeInterval = 3.0
        static let one: CGFloat = 1

        enum Label {
            static let fontSize: CGFloat = 14
            static let verticalPadding: CGFloat = 12
            static let horizontalPadding: CGFloat = 16
        }

        enum ToastView {
            static let backgroundAlpha: CGFloat = 0.75
            static let cornerRadius: CGFloat = 12
            static let horizontalMargin: CGFloat = 16
            static let bottomMargin: CGFloat = 16
        }

        enum Animation {
            static let duration: TimeInterval = 0.3
        }
    }
    
    // MARK: - INTERNAL METHODS
    
    func showToast(_ message: String, duration: TimeInterval = Constants.defaultDuration) {
        let toast = makeToastView(message: message)

        view.addSubview(toast)
        setupToastConstraints(toast)
        animateToast(toast, duration: duration)
    }

    // MARK: - PRIVATE METHODS

    private func makeToastView(message: String) -> UIView {
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Label.fontSize, weight: .medium)
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false

        let toast = UIView()
        toast.backgroundColor = UIColor.black.withAlphaComponent(Constants.ToastView.backgroundAlpha)
        toast.layer.cornerRadius = Constants.ToastView.cornerRadius
        toast.alpha = .zero
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: toast.topAnchor, constant: Constants.Label.verticalPadding),
            label.bottomAnchor.constraint(equalTo: toast.bottomAnchor, constant: -Constants.Label.verticalPadding),
            label.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: Constants.Label.horizontalPadding),
            label.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -Constants.Label.horizontalPadding),
        ])

        return toast
    }

    private func setupToastConstraints(_ toast: UIView) {
        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.ToastView.horizontalMargin),
            toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.ToastView.horizontalMargin),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.ToastView.bottomMargin),
        ])
    }

    private func animateToast(_ toast: UIView, duration: TimeInterval) {
        UIView.animate(withDuration: Constants.Animation.duration) {
            toast.alpha = Constants.one
        } completion: { _ in
            UIView.animate(withDuration: Constants.Animation.duration, delay: duration) {
                toast.alpha = .zero
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}
