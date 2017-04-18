//
//  Sale.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import Foundation

class Sale {
    let id: Int
    let productID: Int
    let price: Double
    let initialPrice: Double
    let count: Int
    let orderID: Int
    
    init(id: Int, productID: Int, price: Double, initialPrice: Double, count: Int, orderID: Int) {
        self.id = id
        self.orderID = orderID
        self.price = price
        self.initialPrice = initialPrice
        self.count = count
        self.productID = productID
    }
}

class FullSale {
    let id: Int
    let product: Product
    let price: Double
    let initialPrice: Double
    let count: Int
    let orderID: Int
    
    init(id: Int, product: Product, price: Double, initialPrice: Double, count: Int, orderID: Int) {
        self.id = id
        self.orderID = orderID
        self.price = price
        self.initialPrice = initialPrice
        self.count = count
        self.product = product
    }
}
