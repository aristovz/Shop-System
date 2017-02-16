//
//  ReportCell.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit
import FontAwesome_swift

class ReportCell: UITableViewCell {

    @IBOutlet weak var const: NSLayoutConstraint!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var procentIcon: UIImageView!
    @IBOutlet weak var clockIcon: UIImageView!
    
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var sales = [Sale]()
    var products = [Product]()
    var client: Client?

    var summa = 0.0
    var profit = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.register(UINib(nibName: "SaleCell", bundle: nil), forCellReuseIdentifier: "saleCell")
        tableView.dataSource = self
        tableView.delegate = self
    
        userIcon.image = UIImage.fontAwesomeIconWithName(name: .User , textColor: .darkGray, size: CGSize(width: 34, height: 34))
        procentIcon.image = UIImage.fontAwesomeIconWithName(name: .Percent, textColor: .lightGray, size: CGSize(width: 12, height: 12))
        clockIcon.image = UIImage.fontAwesomeIconWithName(name: .ClockO, textColor: .lightGray, size: CGSize(width: 12, height: 12))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            let inset: CGFloat = 15
            var frame = newFrame
            frame.origin.x += inset
            frame.size.width -= 2 * inset
            super.frame = frame
        }
    }
    
    public func updateData() {
        summa = 0
        profit = 0
        if let client = self.client {
            self.nameLabel.text = client.name
            self.discountLabel.text = "\(client.discount)"
        }
        else {
            self.nameLabel.text = "---"
            self.discountLabel.text = "0"
        }
        
        tableView.reloadData()
    }
}

extension ReportCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sales.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "saleCell") as! SaleCell
        
        let discount = client?.discount ?? 0
        let currentSale = sales[indexPath.row]
        let product = products[indexPath.row]
        cell.productName.text = product.name
        cell.countLabel.text = "\(currentSale.count) \(product.type == 0 ? "гр" : "шт")"
        
        let localSumma = product.price * Double(currentSale.count) * Double(1 - Double(discount) / 100)
        profit += localSumma - (currentSale.initialPrice * Double(currentSale.count))
        
        cell.sumLabel.text = String(format: "%g ₽", localSumma)
        
        summa += localSumma
        
        self.sumLabel.text = String(format: "%g ₽", summa)
        self.profitLabel.text = String(format: "%g ₽", profit)
        return cell
    }
}
