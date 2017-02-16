//
//  ReportController.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit

class ReportController: UITableViewController {
    var orders: [Order]?
    var workers = [Worker]()
    var sales = [Sale]()
    var categories = [Category]()
    var products = [Product]()
    var clients = [Client]()
    
    var count = 0
    
    var dates = [Date()]
    var offline = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ReportCell", bundle: nil), forCellReuseIdentifier: "reportCell")
        tableView.backgroundView = nil
        
        if offline {
            let button = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(ReportController.closeController))
            self.navigationItem.setRightBarButton(button, animated: true)
        }
        
        let tabBar = self.tabBarController?.tabBar
        tabBar?.items![0].image = #imageLiteral(resourceName: "list")
        tabBar?.items![0].title = "Сегодня"
        tabBar?.items![1].image = #imageLiteral(resourceName: "move")
        tabBar?.items![1].title = "Склад"
        tabBar?.items![2].image = #imageLiteral(resourceName: "line-chart")
        tabBar?.items![2].title = "Отчет"
        tabBar?.items![3].image = #imageLiteral(resourceName: "scanner")
        tabBar?.items![3].title = "Сканер"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ReportController.refreshData), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshControl?.beginRefreshingManually()
    }
    
    var noDataLabel: UILabel {
        get {
            let label = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: Global.screenSize.width, height: 30)))
            label.text = "Нет продаж"
            label.textAlignment = .center
            label.font = UIFont(name: "Helvetica Neue", size: 14)
            label.textColor = UIColor.lightBlueTextColor()
            label.tag = 1
            return label
        }
    }
    
    //var timeRequest = Date()
    func refreshData() {
        //timeRequest = Date()
        if !offline {
            API.OrdersManager.getAllOrdersWithSalesInDays(days: self.dates) { (orders) in
                //print(orders)
                self.orders = orders
                
                if (orders.count == 0) {
                    self.tableView.addSubview(self.noDataLabel)
                }
                else {
                    if let label = self.tableView.viewWithTag(1) as? UILabel {
                        label.removeFromSuperview()
                    }
                }
                
                self.getOffline()
            }
        }
        else {
            getOffline()
        }
    }
    
    func getOffline() {
        let tempOrders = self.orders
        self.orders = nil
        
        API.WorkersManager.getAllWorkers(needDeleted: true) { (workers) in
            //print(workers)
            self.workers = workers
            
            API.CategoriesManager.getAllCategories() { (categories) in
                //print(categories)
                self.categories = categories
                
                API.ProductsManager.getAllProducts(needDeleted: true) { (products) in
                    //print(categories)
                    self.products = products
                    
                    API.ClientsManager.getAllClients(needDeleted: true) { (clients) in
                        //print(categories)
                        self.clients = clients
                        self.orders = tempOrders?.sorted { $0.date > $1.date }
                        
//                        let components = Calendar.current.dateComponents([.second, .nanosecond], from: self.timeRequest, to: Date())
//                        print("\(components.second!):\(components.nanosecond!)")
                        
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }

    func closeController() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func exitButtonAction(_ sender: UIBarButtonItem) {
        Global.appDelegate.loadAuthorizationController(parentViewController: self)
    }
}

extension ReportController {
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return orders == nil ? 0 : orders!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(44) * CGFloat(count) + CGFloat(112)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell") as! ReportCell
        
        if let currentOrder = orders?[indexPath.section] {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium

            cell.dateLabel.text = "\(orders![indexPath.section].date.timeAgo)"//formatter.string(from: orders![indexPath.section].date)
            cell.sales = currentOrder.sales
            cell.client = currentOrder.clientID != nil ? clients.first(where: {$0.id == currentOrder.clientID}) : nil
            cell.products = currentOrder.sales.map { sale in products.first { $0.id == sale.productID }! }

            count = cell.sales.count
            
            cell.updateData()
        }
        
        return cell
    }
}
