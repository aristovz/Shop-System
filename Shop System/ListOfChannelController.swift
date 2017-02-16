//
//  ListOfChannelController.swift
//  Shop System
//
//  Created by Pavel Aristov on 08.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import SwiftyJSON

class ListOfChannelController: UITableViewController {

    var listOfChannel = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ReportController.refreshData), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshControl?.beginRefreshingManually()
    }
    
    func refreshData() {
        API.TransactionsManager.getWaiting { (result) in
            self.refreshControl?.endRefreshing()
            self.listOfChannel = result
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listOfChannel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "channelCell")
        
        cell?.textLabel?.text = listOfChannel[indexPath.row]["name"].stringValue
        cell?.detailTextLabel?.text = "Создан \(listOfChannel[indexPath.row]["date"].stringValue.dateFromISO8601!.timeAgo)"
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        API.TransactionsManager.startMonitoring(id: listOfChannel[indexPath.row]["id"].intValue, requestEnd: { (result) in
            if result {
                let vc = Global.mainStoryBoard.instantiateViewController(withIdentifier: "scanerController") as! ScanerController
                vc.currentChannel = self.listOfChannel[indexPath.row]
                self.present(vc, animated: true, completion: nil)
            }
            else {
                print("error openning channel")
            }
        })
    }
}
