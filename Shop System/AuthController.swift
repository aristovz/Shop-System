//
//  ViewController.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit
import Alamofire

class AuthController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.loginView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.loginView.transform = CGAffineTransform(translationX: 0, y: -80)
        }, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        let username = usernameTextField.text!
        let pass = passwordTextField.text!
        
        let parameters: [String: Any] = [
            "username": username,
            "password": pass,
            "saveToken": 1
        ]
        
        Alamofire.request(Global.urlPath + "auth", method: .post, parameters: parameters)
            .responseJSON { (response) in
                let res = response.result.value! as! NSDictionary
                
                if res["error"] != nil {
                    self.usernameTextField.shake()
                    self.passwordTextField.shake()
                }
                else if (res["success"] as! Bool) {
                    print("Успешная авторизация!\naccess_token = \(res["access_token"]!)")
                    
                    Global.access_token = res["access_token"]! as? String
                    Global.appDelegate.loadMenuController(parentViewController: self)
                }
        }
    }
}
