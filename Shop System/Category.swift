//
//  Category.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import Foundation

class Category {
    let id: Int
    let name: String
    let parentID: Int?
    
    init (id: Int, name: String, parentID: Int? = nil) {
        self.id = id
        self.name = name
        self.parentID = parentID
    }
}
