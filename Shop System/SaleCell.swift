//
//  SaleCell.swift
//  Shop System
//
//  Created by Pavel Aristov on 06.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit

class SaleCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
