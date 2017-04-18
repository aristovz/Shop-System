//
//  Order.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import Foundation

class Order {
    let id: Int
    var clientID: Int?
    var workerID: Int
    let date: Date
    let discount: Int
    var sales = [Sale]()
    
    init(id: Int, clientID: Int? = nil, workerID: Int, date: Date, discount: Int) {
        self.id = id
        self.clientID = clientID
        self.workerID = workerID
        self.date = date
        self.discount = discount
    }
    
    func getSum() -> (sum: Double, profit: Double){
        var allSum = 0.0
        var profit = 0.0
        
        for sale in sales {
            let localSum = sale.price * Double(sale.count) - (sale.price * Double(sale.count * self.discount)) / 100
            allSum += localSum
            profit += localSum - sale.initialPrice * Double(sale.count)
        }
        
        return (allSum, profit)
    }
}

class FullOrder {
    let id: Int
    var client: Client?
    var worker: Worker
    let date: Date
    let discount: Int
    var sales = [FullSale]()
    
    init(id: Int, client: Client? = nil, worker: Worker, date: Date, discount: Int) {
        self.id = id
        self.client = client
        self.worker = worker
        self.date = date
        self.discount = discount
    }
    
    func getSum() -> (sum: Double, profit: Double){
        var allSum = 0.0
        var profit = 0.0
        
        for sale in sales {
            let localSum = sale.price * Double(sale.count) - (sale.price * Double(sale.count * self.discount)) / 100
            allSum += localSum
            profit += localSum - sale.initialPrice * Double(sale.count)
        }
        
        return (allSum, profit)
    }
}
