//
//  ShowProductController.swift
//  Shop System
//
//  Created by Pavel Aristov on 12.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit

class ShowProductController: UIViewController {

    @IBOutlet weak var resLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var productNameField: UITextField!
    
    var currentCode = ""
    var currentProduct: ProductCode? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if currentProduct != nil {
            codeLabel.text = currentProduct!.code
            productNameField.text = currentProduct!.name
        }
        else {
            codeLabel.text = currentCode
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addProductAction(_ sender: UIButton) {
        API.ProdManager.add(code: currentCode, name: productNameField.text!) { (res) in
            self.resLabel.text = res
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
