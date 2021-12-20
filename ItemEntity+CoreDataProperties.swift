//
//  ItemEntity+CoreDataProperties.swift
//  Final_Finalproject
//
//  Created by dong eun shin on 2020/11/11.
//  Copyright © 2020 dong eun shin. All rights reserved.
//
//

import Foundation
import CoreData


extension ItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemEntity> {
        return NSFetchRequest<ItemEntity>(entityName: "Item")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: Int16
    @NSManaged public var category: String?
    @NSManaged public var eDay: Date?

}
