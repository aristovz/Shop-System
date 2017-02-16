//
//  Product.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import Foundation

class Product {
    let id: Int
    let name: String
    let type: Int
    let categoryID: Int
    let price: Double
    let initialPrice: Double
    
    init (id: Int, name: String, type: Int, categoryID: Int, price: Double, initialPrice: Double) {
        self.id = id
        self.name = name
        self.type = type
        self.categoryID = categoryID
        self.price = price
        self.initialPrice = initialPrice
    }
}
