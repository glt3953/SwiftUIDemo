//
//  Item.swift
//  SwiftUIDemo
//
//  Created by 宁侠 on 2025/4/1.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
