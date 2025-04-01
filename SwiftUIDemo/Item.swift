//
//  Item.swift
//  SwiftUIDemo
//
//  Created by 宁侠 on 2025/4/1.
//

import Foundation
import CoreData

@objc(Item)
class Item: NSManagedObject, Identifiable {
    @NSManaged public var timestamp: Date
    
    static func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
}

extension Item {
    static func createWith(timestamp: Date, in context: NSManagedObjectContext) -> Item {
        let item = Item(context: context)
        item.timestamp = timestamp
        return item
    }
}
