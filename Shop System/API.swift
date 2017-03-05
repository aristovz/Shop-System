//
//  API.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class API {
    //requestEnd(JSON(response.result.value!)["result"].boolValue)
    
    class WorkersManager {
        class func getAllWorkers(needDeleted: Bool = false, requestEnd:@escaping ([Worker]) -> ()) {
            var workers = [Worker]()
            Alamofire.request(Global.urlPath + "workers.getAll", method: .get, parameters: ["needDeleted" : needDeleted ? 1 : 0, "access_token" : Global.access_token!]).responseJSON { (response) in
                //print(response.result.value)
                
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        for worker in json["workers"].arrayValue {
                            let currentWorker = Worker(id: worker["id"].intValue, name: worker["name"].stringValue, phone: worker["phone"].stringValue)
                                workers.append(currentWorker)
                        }
                    case .failure(let error):
                        print(error)
                }
                
                workers.sort(by: { $0.name < $1.name })
                requestEnd(workers)
            }
        }
    }
    
    class OrdersManager {
        class func getAllOrders(requestEnd:@escaping ([Order]) -> ()) {
            var orders = [Order]()
            Alamofire.request(Global.urlPath + "orders.getAll", method: .get, parameters: ["access_token" : Global.access_token!]).responseJSON { (response) in
                //print(response.result.value)
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for order in json["orders"].arrayValue {
                        let currentOrder = Order(id: order["id"].intValue, clientID: order["clientID"].int, workerID: order["workerID"].intValue, date: Date(timeIntervalSince1970: TimeInterval(order["date"].intValue)), discount: order["discount"].intValue)
                        orders.append(currentOrder)
                    }
                case .failure(let error):
                    print(error)
                }
                
                requestEnd(orders)
            }
        }
        
        class func getAllOrdersWithSales(requestEnd:@escaping ([Order]) -> ()) {
            var orders = [Order]()
            API.SalesManager.getAllSales(requestEnd: { (sales) in
                Alamofire.request(Global.urlPath + "orders.getAll", method: .get, parameters: ["access_token" : Global.access_token!]).responseJSON { (response) in
                    //print(response.result.value)
                    
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        for order in json["orders"].arrayValue {
                            let currentOrder = Order(id: order["id"].intValue, clientID: order["clientID"].int, workerID: order["workerID"].intValue, date: order["date"].stringValue.dateFromISO8601!, discount: order["discount"].intValue)
                            
                            for sale in sales.filter({ $0.orderID == currentOrder.id }) {
                                currentOrder.sales.append(sale)
                            }
                            orders.append(currentOrder)
                        }
                    case .failure(let error):
                        print(error)
                    }
                    
                    requestEnd(orders)
                }
            })
        }
        
        class func getAllOrdersWithSalesInDays(days: [Date], requestEnd:@escaping ([Order]) -> ()) {
            var orders = [Order]()
            API.SalesManager.getAllSales(requestEnd: { (sales) in
                
                let formater = DateFormatter()
                formater.calendar = Calendar.current
                formater.timeZone = TimeZone.current
                formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let dates = days.map { formater.string(from: $0) }
                
                Alamofire.request(Global.urlPath + "orders.getAllInDates", method: .get, parameters: ["days" : JSON(dates), "access_token" : Global.access_token!]).responseJSON { (response) in
                    //print(response.result.value ?? "123")
                    
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        for order in json["orders"].arrayValue {
                            let currentOrder = Order(id: order["id"].intValue, clientID: order["clientID"].int, workerID: order["workerID"].intValue, date: order["date"].stringValue.dateFromISO8601!, discount: order["discount"].intValue)
                            
                            for sale in sales.filter({ $0.orderID == currentOrder.id }) {
                                currentOrder.sales.append(sale)
                            }
                            orders.append(currentOrder)
                        }
                    case .failure(let error):
                        print(error)
                    }
                    
                    requestEnd(orders)
                }
            })
        }
    }
    
    class SalesManager {
        class func getAllSales(requestEnd:@escaping ([Sale]) -> ()) {
            var sales = [Sale]()
            Alamofire.request(Global.urlPath + "sales.getAll", method: .get, parameters: ["access_token" : Global.access_token!]).responseJSON { (response) in
                //print(response.result.value)
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for sale in json["sales"].arrayValue {
                        let currentSale = Sale(id: sale["id"].intValue, productID: sale["productID"].intValue, price: sale["price"].doubleValue, initialPrice: sale["initialPrice"].doubleValue, count: sale["count"].intValue, orderID: sale["orderID"].intValue)
                        sales.append(currentSale)
                    }
                case .failure(let error):
                    print(error)
                }
                
                requestEnd(sales)
            }
        }
    }
    
    class CategoriesManager {
        class func getAllCategories(requestEnd:@escaping ([Category]) -> ()) {
            var categories = [Category]()
            Alamofire.request(Global.urlPath + "category.getAll", method: .get, parameters: ["access_token" : Global.access_token!]).responseJSON { (response) in
                //print(response.result.value)

                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for category in json["categories"].arrayValue {
                        let currentCategory = Category(id: category["id"].intValue, name: category["name"].stringValue, parentID: category["parentID"].int)
                        categories.append(currentCategory)
                    }
                case .failure(let error):
                    print(error)
                }
                
                requestEnd(categories)
            }
        }
    }
    
    class ProductsManager {
        class func addProduct(name: String, type: Int, categoryID: Int, price: Double, initialPrice: Double, requestEnd:@escaping (Bool?) -> ()) {
            let parameters = ["name" : name,
                              "type" : type,
                              "categoryID" : categoryID,
                              "price" : price,
                              "initialPrice" : initialPrice,
                              "access_token" : Global.access_token!] as [String : Any]
            
            Alamofire.request(Global.urlPath + "product.add", method: .post, parameters: parameters).responseJSON { (response) in
                //print(response.result.value)
                
                if response.result.value != nil {
                    requestEnd(JSON(response.result.value!)["result"].boolValue)
                }
                else {
                    requestEnd(nil)
                }
            }
        }
        
        class func deleteProduct(id: Int, requestEnd:@escaping (Bool?) -> ()) {
            let parameters = ["id" : id,
                              "access_token" : Global.access_token!] as [String : Any]
            
            Alamofire.request(Global.urlPath + "product.delete", method: .post, parameters: parameters).responseJSON { (response) in
                //print(response.result.value)
                
                if response.result.value != nil {
                    requestEnd(JSON(response.result.value!)["result"].boolValue)
                }
                else {
                    requestEnd(nil)
                }
            }
        }
        
        class func getAllProducts(needDeleted: Bool = false, requestEnd:@escaping ([Product]) -> ()) {
            var products = [Product]()
            Alamofire.request(Global.urlPath + "product.getAll", method: .get, parameters: ["needDeleted" : needDeleted ? 1 : 0, "access_token" : Global.access_token!]).responseJSON { (response) in
                //print(response.result.value)
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for product in json["products"].arrayValue {
                        let currentProduct = Product(id: product["id"].intValue, name: product["name"].stringValue, type: product["type"].intValue, categoryID: product["categoryID"].intValue, price: product["price"].doubleValue, initialPrice: product["initialPrice"].doubleValue)
                        products.append(currentProduct)
                    }
                case .failure(let error):
                    print(error)
                }
                
                requestEnd(products)
            }
        }
    }
    
    class ClientsManager {
        class func addClient(card: Int, name: String, discount: Int, phone: String = "", requestEnd:@escaping (Bool?) -> ()) {
            let parameters = ["name" : name,
                              "discount" : discount,
                              "id" : card,
                              "phone" : phone,
                              "access_token" : Global.access_token!] as [String : Any]
            
            Alamofire.request(Global.urlPath + "client.add", method: .post, parameters: parameters).responseJSON { (response) in
                //print(response.result.value)
                if response.result.value != nil {
                    requestEnd(JSON(response.result.value!)["result"].boolValue)
                }
                else {
                    requestEnd(nil)
                }
            }
        }
        
        class func getByCard(card: Int, needDeleted: Bool = false, requestEnd:@escaping ([Client]) -> ()) {
            var clients = [Client]()
            Alamofire.request(Global.urlPath + "client.getByCard", method: .get, parameters: ["card" : card, "needDeleted" : needDeleted ? 1 : 0, "access_token" : Global.access_token!]).responseJSON { (response) in
                //print(response.result.value)
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for client in json["clients"].arrayValue {
                        let currentClient = Client(id: client["cid"].intValue, name: client["name"].stringValue, phone: client["phone"].stringValue, discount: client["discount"].intValue, card: client["id"].intValue, summa: client["summa"].doubleValue)
                        clients.append(currentClient)
                    }
                case .failure(let error):
                    print(error)
                }
                
                requestEnd(clients)
            }
        }
        class func getAllClients(needDeleted: Bool = false, requestEnd:@escaping ([Client]) -> ()) {
            var clients = [Client]()
            Alamofire.request(Global.urlPath + "client.getAll", method: .get, parameters: ["needDeleted" : needDeleted ? 1 : 0, "access_token" : Global.access_token!]).responseJSON { (response) in
                //print(response.result.value)
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for client in json["clients"].arrayValue {
                        let currentClient = Client(id: client["cid"].intValue, name: client["name"].stringValue, phone: client["phone"].stringValue, discount: client["discount"].intValue, card: client["id"].intValue, summa: client["summa"].doubleValue)
                        clients.append(currentClient)
                    }
                case .failure(let error):
                    print(error)
                }
                
                requestEnd(clients)
            }
        }
    }
    
    class ProdManager {
        class func add(code: String, name: String, requestEnd:@escaping (String) -> ()) {
            Alamofire.request(Global.urlPath + "prod.add", method: .post, parameters: ["code" : code, "name" : name, "access_token" : Global.access_token!]).responseString { (response) in
                //print(response.result.value)
                
                requestEnd(response.result.value!)
            }
        }
        
        class func getProductByCode(code: String, requestEnd:@escaping (ProductCode?) -> ()) {
            Alamofire.request(Global.urlPath + "prod.getByCode", method: .get, parameters: ["code" : code, "access_token" : Global.access_token!]).responseJSON { (response) in
                //print(response.result.value)
                var currentProduct: ProductCode?
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)["result"]
                    
                    if (json != nil) {
                        currentProduct = ProductCode(id: json["id"].intValue, name: json["name"].stringValue, code: json["code"].stringValue)
                    }
                    
                case .failure(let error):
                    print(error)
                }
                
                requestEnd(currentProduct)
            }
        }
    }
    
    class TransactionsManager {
        class func getWaiting(requestEnd:@escaping ([JSON]) -> ()) {
            Alamofire.request(Global.urlPath + "transactions.getWaiting", method: .get, parameters: ["access_token" : Global.access_token!]).responseJSON { (response) in
                //print(response.result.value)
                requestEnd(JSON(response.result.value!)["transactions"].arrayValue)
            }
        }
        
        class func startMonitoring(id: Int, requestEnd:@escaping (Bool) -> ()) {
            Alamofire.request(Global.urlPath + "transactions.startMonitoring", method: .post, parameters: ["id" : id, "access_token" : Global.access_token!]).responseJSON { (response) in
                
                requestEnd(JSON(response.result.value!)["result"].boolValue)
            }
        }
        
        class func endMonitoring(id: Int, requestEnd:@escaping (Bool) -> ()) {
            Alamofire.request(Global.urlPath + "transactions.endMonitoring", method: .post, parameters: ["id" : id, "access_token" : Global.access_token!]).responseJSON { (response) in
                
                requestEnd(JSON(response.result.value!)["result"].boolValue)
            }
        }
        
        class func addCode(id: Int, code: String, requestEnd:@escaping (Bool?) -> ()) {
            Alamofire.request(Global.urlPath + "transactions.addCode", method: .post, parameters: ["id" : id, "code" : code, "access_token" : Global.access_token!]).responseJSON { (response) in
                
                if response.result.value != nil {
                    requestEnd(JSON(response.result.value!)["result"].boolValue)
                }
                else {
                    requestEnd(nil)
                }
            }
        }
    }
}
