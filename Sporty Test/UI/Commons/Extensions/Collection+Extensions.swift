//
//  Collection+Extensions.swift
//  Sporty Test
//
//  Created by Victor Marcel on 27/02/26.
//

import Foundation

extension Collection {
    
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
