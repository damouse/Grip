//
//  Rollback.swift
//  Grip
//
//  Created by Mickey Barboi on 8/27/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
Responsible for undo functionality. Gets called as events occurs, stores those events in actions, and the plays them back when needed
*/

import Foundation

class Rollback : NSObject {
    var actions = [RollbackAction]()
    var blockUndo: ((product: ProductReceipt) -> Void)
    
    let maxActions = 50
    
    
    init(undoBlock: ((product: ProductReceipt) -> Void)) {
        blockUndo = undoBlock
    }
    
    func actionProductSelection(product: ProductReceipt) {
        actions.append(RollbackAction(products: [product]))
    }
    
    func actionPackageSelection(alteredProducts: [ProductReceipt]) {
        actions.append(RollbackAction(products: alteredProducts))
    }
    
    func checkBounds() {
        //ensure the number of queued actions doesn't pass a certain threshold so we don't crash the app
        if actions.count > maxActions {
            actions.removeAtIndex(0)
        }
    }
    
    func undo() {
        if actions.count < 1 {
            return
        }
        
        let action = actions.removeLast()
        for product in action.changedProducts {
            blockUndo(product: product)
        }
    }
}

/**
Wrapper class to encapsulate product change actions
*/
class RollbackAction {
    var changedProducts = [ProductReceipt]()
    
    init(products: [ProductReceipt]) {
        changedProducts = products
    }
}