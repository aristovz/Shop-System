//
//  ClientCell.swift
//  Shop System
//
//  Created by Pavel Aristov on 30.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit

class ClientCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
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
