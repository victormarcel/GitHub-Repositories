//
//  WrapperView.swift
//  Sporty Test
//
//  Created by Victor Marcel on 26/02/26.
//

import UIKit

public class WrapperView<T: UIView>: UIView {
    
    // MARK: - INTERNAL PROPERTIES
    
    let view: T
    
    // MARK: - INITIALIZERS
    
    init(view: T) {
        self.view = view
        
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - INTERNAL PROPERTIES
    
    func setDynamicHeight() {
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
