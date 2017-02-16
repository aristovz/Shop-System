//
//  TodayViewController.swift
//  Shop-System Widget
//
//  Created by Pavel Aristov on 02.12.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var guestsLabel: UILabel!
    @IBOutlet weak var refreshDateLabel: UILabel!
    
    var orders = [Order]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        refreshData()
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func refreshButtonAction(_ sender: UIButton) {
        refreshData()
    }
    
    func refreshData() {
        guard Global.access_token != nil else
        {
            print("ERROR NOT_AUTHORIZED")
            return
        }
        
        API.OrdersManager.getAllOrdersWithSales { (orders) in
            self.orders = orders
            var allSum = 0.0
            var profit = 0.0
            var countGuests = 0
            for order in orders {
                let localSum = order.getSum()
                allSum += localSum.sum
                profit += localSum.profit
                countGuests += order.sales.count
            }

            self.sumLabel.text = String(format: "%g ₽", allSum)
            self.profitLabel.text = String(format: "%g ₽", profit)
            self.guestsLabel.text = "\(countGuests)"
            
            self.refreshDateLabel.text = "Обновлено в \(Calendar.current.component(.hour, from: Date())):\(Calendar.current.component(.minute, from: Date()) < 10 ? "0\(Calendar.current.component(.minute, from: Date()))" : "\(Calendar.current.component(.minute, from: Date()))")"
        }
    }
    
    
}
