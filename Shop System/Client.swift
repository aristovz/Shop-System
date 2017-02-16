//
//  Client.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import Foundation

class Client {
    let id: Int
    let name: String
    let phone: String
    let discount: Int
    let card: Int
    let summa: Double
    
    init(id: Int, name: String, phone: String, discount: Int, card: Int, summa: Double) {
        self.id = id
        self.name = name
        self.phone = phone
        self.discount = discount
        self.card = card
        self.summa = summa
    }
}
