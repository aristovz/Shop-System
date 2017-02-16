//
//  Worker.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import Foundation

class Worker {
    let id: Int
    let name: String
    let phone: String
    
    init(id: Int, name: String, phone: String){
        self.id = id
        self.name = name
        self.phone = phone
    }
}
