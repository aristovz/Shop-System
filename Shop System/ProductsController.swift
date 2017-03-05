//
//  ProductsController.swift
//  Shop System
//
//  Created by Pavel Aristov on 02.12.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit

class ProductsController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var loadDataIndicator: UIActivityIndicatorView!
    
    var categories = [Category]()
    var products = Dictionary<Int, [Product]>()
    var subcategories = [Category]()
    
    var countProducts: Int = 0
    
    var currentCategory: Category? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "productCell")
        collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.refreshControl?.beginRefreshingManually()
    }
    
    func refreshData() {
        loadDataIndicator.startAnimating()
        API.CategoriesManager.getAllCategories { (categories) in
            self.categories = categories
            categories.forEach({ (category) in
                self.products[category.id] = [Product]()
            })
            
            if self.categories.count != 0 {
                API.ProductsManager.getAllProducts(requestEnd: { (products) in
                    for prod in products {
                        self.products[prod.categoryID]!.append(prod)
                    }
                    
                    self.tableView.refreshControl?.endRefreshing()
                    self.loadDataIndicator.stopAnimating()
                    self.loadNewData(category: self.currentCategory)
                })
            }
        }
    }
    
    func loadNewData(category: Category?) {
        self.title = category != nil ? category!.name : "Все категории"
        
        //currentCategoryLabel.text = category != nil ? category!.name : "Все категории"
        
        currentCategory = category
        self.subcategories = categories.filter({$0.parentID == category?.id})
        
        self.navigationItem.leftBarButtonItem?.title = parentCategory == nil ? "< Все категории" : "< \(parentCategory!.name)"
        self.navigationItem.leftBarButtonItem?.isEnabled = category != nil
        if category == nil {
            self.navigationItem.leftBarButtonItem?.title? = ""
        }

        tableView.reloadData()
        collectionView.reloadData()
    }
    
    var parentCategory: Category? {
        get {
            if currentCategory == nil || currentCategory?.parentID == nil { return nil }
            
            return categories.filter({$0.id == currentCategory!.parentID}).first!
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        loadNewData(category: parentCategory)
    }
    
    @IBAction func addProductButtonAction(_ sender: UIBarButtonItem) {
        let vc = Global.mainStoryBoard.instantiateViewController(withIdentifier: "addProductController") as! AddProductController
        vc.categories = self.categories
        vc._selectedCategory = currentCategory
        present(vc, animated: true, completion: nil)
    }
    
}

extension ProductsController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard currentCategory != nil else { return 0 }
        
        return products[currentCategory!.id]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! ProductCell
        
        if let currentProduct = products[currentCategory!.id]?[indexPath.row] {
            cell.productNameLabel.text = currentProduct.name
            cell.countLabel.text = "\(0) \(currentProduct.type == 0 ? "гр" : "шт")"
            cell.priceLabel.text = String(format: "%g ₽", currentProduct.price)
            cell.initialPriceLabel.text = String(format: "%g ₽", currentProduct.initialPrice)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if let currentProduct = products[currentCategory!.id]?[indexPath.row] {
                products[currentCategory!.id]?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                API.ProductsManager.deleteProduct(id: currentProduct.id, requestEnd: { (result) in
                    if let res = result {
                        if result == false {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
    }
}

extension ProductsController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subcategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        
        let currentCategory = subcategories[indexPath.row]
        
        cell.categoryNameLabel.text = currentCategory.name
        
        countProducts = 0
        getCountProducts(category: currentCategory)
        
        cell.countProductsLabel.text = "\(countProducts) продуктов"
        
        return cell
    }
    
    func getCountProducts(category: Category) {
        for cat in categories {
            if cat.parentID == category.id {
                getCountProducts(category: cat)
            }
        }
        
        if let count = products[category.id]?.count {
            countProducts += count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadNewData(category: subcategories[indexPath.row])
    }
}
