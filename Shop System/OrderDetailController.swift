//
//  OrderDetailController.swift
//  Shop System
//
//  Created by Pavel Aristov on 06.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit

class OrderDetailController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    
    @IBOutlet weak var workerNameLabel: UILabel!
    
    var order: Order?
    var client: Client?
    var products = [Product]()
    var sales = [Sale]()
    var worker: Worker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SaleCell", bundle: nil), forCellReuseIdentifier: "saleCell")
        
        workerNameLabel.text = worker!.name
        if (client != nil) {
            clientNameLabel.text = client!.name
            discountLabel.text = "\(client!.discount) %"
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension OrderDetailController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sales.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "saleCell") as! SaleCell
        
        let currentSale = sales[indexPath.row]
        let currentPoduct = products.first(where: {$0.id == currentSale.productID})!
        
        cell.productName.text = currentPoduct.name
        cell.countLabel.text = "\(currentSale.count) \(currentPoduct.type == 0 ? "гр" : "шт")"
        
        let discount = client?.discount ?? 0
        cell.sumLabel.text = "\(currentPoduct.price * Double(currentSale.count) * Double(1 - Double(discount) / 100)) ₽"
    
        return cell
    }
}


