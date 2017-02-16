//
//  AddClientController.swift
//  Shop System
//
//  Created by Pavel Aristov on 02.12.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit
import SCLAlertView
import AVKit

class AddClientController: UIViewController, UITextFieldDelegate, ScanerViewDelegate {
    
    @IBOutlet weak var qrCodeImage: UIButton!
    
    @IBOutlet weak var cardField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var discountLabel: UITextField!
    
    @IBOutlet weak var activeView: UIView!
    
    var scanerView: ScanerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        qrCodeImage.setImage(qrCodeImage.currentImage?.resize(to: CGSize(width: 20, height: 20)), for: .normal)
    }
    
    func scanerView(_ scanerView: ScanerView, didDetectCode code: String) {
        if let cardNum = Int(code) {
            self.scanerView?.isHidden = true
            cardField.text = String(cardNum)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.activeView.transform = CGAffineTransform(translationX: 0, y: -80)
        }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.activeView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    @IBAction func qrCodeScanAction(_ sender: UIButton) {
        self.scanerView?.isHidden = !self.scanerView!.isHidden
        if self.scanerView == nil {
            sender.backgroundColor = UIColor.green
            scanerView = ScanerView(frame: CGRect(x: activeView.bounds.origin.x, y: cardField.frame.origin.y + cardField.frame.height, width: activeView.frame.width, height: discountLabel.frame.origin.y + discountLabel.frame.height - cardField.frame.origin.y - cardField.frame.height))
            scanerView?.delegate = self
            scanerView?.startMonitoring()
            activeView.addSubview(scanerView!)
        }
        else {
            sender.backgroundColor = UIColor.clear
            self.scanerView!.removeFromSuperview()
            self.scanerView = nil
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        guard Int(cardField.text!) != nil else {
            cardField.shake()
            return
        }
        
        guard nameField.text != "" else {
            nameField.shake()
            return
        }
        
        guard phoneField.text != "" else {
            phoneField.shake()
            return
        }
        
        guard Int(discountLabel.text!) != nil && Int(discountLabel.text!)! > 0 && Int(discountLabel.text!)! <= 100 else {
            self.discountLabel.shake()
            return
        }
        
        let waitAlert = Alert.wait.showWait("", subTitle: "", animationStyle: .noAnimation)
        API.ClientsManager.getByCard(card: Int(cardField.text!)!) { (clients) in
            guard clients.count == 0 else {
                waitAlert.close()
                Alert.result.showError("Карта занята!", subTitle: "Владелец: \(clients.first!.name)", duration: 3, animationStyle: .noAnimation)
                self.cardField.shake()
                return
            }
            
            API.ClientsManager.addClient(card: Int(self.cardField.text!)!, name: self.nameField.text!, discount: Int(self.discountLabel.text!)!, phone: self.phoneField.text!, requestEnd: { (result) in
                if result != nil && result! {
                    waitAlert.close()
                    Alert.result.showSuccess("Успешно!", subTitle: "Клиент успешно добавлен", duration: 1, animationStyle: .noAnimation)
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    waitAlert.close()
                    Alert.result.showError("Ошибка!", subTitle: "Не удалось добавить клиента", duration: 3, animationStyle: .noAnimation)
                    self.activeView.shake()
                }
            })
        }
    }
}
