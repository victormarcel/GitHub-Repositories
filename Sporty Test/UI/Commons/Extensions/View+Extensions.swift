//
//  View+Extensions.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import SwiftUI

extension View {
    
    func embeddedInViewController() -> UIViewController {
        UIHostingController(rootView: self)
    }
}
