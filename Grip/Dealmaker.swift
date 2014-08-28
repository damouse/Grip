//
//  Dealmaker.swift
//  Grip
//
//  Created by Mickey Barboi on 8/27/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
This class is responsible for manaing the creation of a receipt and all associated information of that receipt. It
manages the model for the DealViewController.

It persists a list of the active products and allows the table to query to determine product position and state.

It holds the user and customer information. 

It also uses Rollback to manage the undo functionality
*/
import Foundation

class Dealmaker : NSObject {
    var receipt: Receipt
    
    var allProducts = [ProductReceipt]()
    var userPackages = [Package]()
    var customerPackages = [Package]()
    
    var currentProductOrdering = [ProductReceipt]()
    
    
    init(allProducts: [Product], user: User, customer: User, merchandise: Product) {
        //Packages and customer packages may not exist, so do not assume their presence!
        
        receipt = Receipt.createWith(user, customer: customer, merchandise: merchandise)
        
        super.init()
        
        for product in allProducts {
            self.allProducts.append(ProductReceipt.createWith(product))
        }
        
        establishProductOrdering()
    }
    
    
    //MARK: Public Interface-- TableDelegate
    func numberOfProducts() -> Int {
        return self.allProducts.count
    }
    
    func productForIndex(index: Int) -> ProductReceipt? {
        return allProducts[index]
    }
    
    func selectProductAtIndex(index: Int) -> [ProductReceipt] {
        //selects or deselects the cell and product at the given path. This method returns the new order
        // of the products so the table can move them as needed
        
        var selectedProduct = currentProductOrdering[index]
        selectedProduct.active = !selectedProduct.active
        
        establishProductOrdering()
        checkPackageMatch()
        
        return currentProductOrdering
    }
    
    func selectPackage(package: Package) {
        
    }
    
    
    //MARK: Internal
    func checkPackageMatch() -> Void {
        //if the current setup matches a package, "snap" that package into place, replacing the current discount value
        //call DealViewController to change any needed changes
    }
    
    func establishProductOrdering() {
        //internally establishes the array that holds all the product receipts in order
        
        //ppartition the products into active and inactive
        var selectedItems = [ProductReceipt]()
        var unselectedItems = [ProductReceipt]()
        
        for product in allProducts {
            if product.active {
                selectedItems.append(product)
            }
            else {
                unselectedItems.append(product)
            }
        }
        
        //sort each section individually
        selectedItems.sort({$0.product?.order_index < $1.product?.order_index})
        unselectedItems.sort({$0.product?.order_index < $1.product?.order_index})
        
        currentProductOrdering = selectedItems + unselectedItems
    }
}