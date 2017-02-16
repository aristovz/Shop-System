//
//  AddProductController.swift
//  Shop System
//
//  Created by Pavel Aristov on 03.12.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit
import DropDown

class AddProductController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var categoryButtonOutlet: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var initialPriceField: UITextField!
    @IBOutlet weak var typeControl: UISegmentedControl!
    
    @IBOutlet weak var activeView: UIView!

    let dropDown = DropDown()
    
    var categories = [Category]()
    var _selectedCategory: Category? = nil

    var selectedCategory: Category? {
        get { return _selectedCategory }
        set {
            _selectedCategory = newValue
            if let category = newValue {
                categoryButtonOutlet.setTitle(category.name, for: .normal)
                categoryButtonOutlet.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        selectedCategory = _selectedCategory
        
        DropDown.startListeningToKeyboard()
        
        dropDown.anchorView = categoryButtonOutlet
        dropDown.dataSource = categories.map { $0.name }
        
        dropDown.selectionAction = { (index: Int, item: String) in
            self.selectedCategory = self.categories[index]
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func categoryButtonAction(_ sender: UIButton) {
        dropDown.show()
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
       
        guard selectedCategory != nil else {
            categoryButtonOutlet.shake()
            return
        }
        
        guard nameField.text != "" else {
            nameField.shake()
            return
        }
        
        var price: Double = 0
        if let pr = Double(priceField.text!.replacingOccurrences(of: ",", with: ".")) {
            price = pr
        }
        else {
            priceField.shake()
            return
        }
        
        var initialPrice: Double = 0
        if let initialPr = Double(initialPriceField.text!.replacingOccurrences(of: ",", with: ".")) {
            initialPrice = initialPr
            if initialPrice >= price {
                self.initialPriceField.shake()
                self.priceField.shake()
                return
            }
        }
        else {
            self.initialPriceField.shake()
            return
        }
        
        let waitAlert = Alert.wait.showWait("", subTitle: "", animationStyle: .noAnimation)
        API.ProductsManager.addProduct(name: nameField.text!, type: typeControl.selectedSegmentIndex, categoryID: selectedCategory!.id, price: price, initialPrice: initialPrice) { (result) in
            if result != nil && result! {
                waitAlert.close()
                Alert.result.showSuccess("Успешно!", subTitle: "Продукт успешно добавлен", duration: 1, animationStyle: .noAnimation)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                waitAlert.close()
                Alert.result.showError("Ошибка!", subTitle: "Не удалось добавить продукт", duration: 3, animationStyle: .noAnimation)
                self.activeView.shake()
            }
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
