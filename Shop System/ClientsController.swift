//
//  ClientsController.swift
//  Shop System
//
//  Created by Pavel Aristov on 30.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit

class ClientsController: UITableViewController {

    var clients = [Client]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "ClientCell", bundle: nil), forCellReuseIdentifier: "clientCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshControl?.beginRefreshingManually()
    }

    func refreshData() {
        if let label = self.tableView.viewWithTag(1) as? UILabel {
            label.removeFromSuperview()
        }
        
        API.ClientsManager.getAllClients { (clients) in
            self.clients = clients
            self.refreshControl?.endRefreshing()
            if clients.count == 0 { self.tableView.addSubview(self.noClientsLabel) }
            else { self.tableView.reloadData() }
        }
    }
    
    var noClientsLabel: UILabel {
        get {
            let label = UILabel(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 20))
            label.text = "нет клиентов"
            label.textColor = UIColor.lightGray
            label.tag = 1
            return label
        }
    }

    @IBAction func addClientButtonAction(_ sender: UIBarButtonItem) {
        let vc = Global.mainStoryBoard.instantiateViewController(withIdentifier: "addClientController")
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension ClientsController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return clients.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clientCell") as! ClientCell
        
        let currentClient = self.clients[indexPath.section]
        
        cell.nameLabel.text = currentClient.name
        cell.phoneLabel.text = currentClient.phone != "" ? currentClient.phone : "---"
        cell.cardLabel.text = "\(currentClient.card)"
        cell.discountLabel.text = "\(currentClient.discount)"
        cell.sumLabel.text = "\(currentClient.summa)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
}
