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
    
    
    init(undoBlock: ((product: ProductReceipt) -> Void)) {
        blockUndo = undoBlock
    }
    
    func actionProductSelection(product: ProductReceipt) {
        actions.append(RollbackAction(products: [product]))
    }
    
    func actionPackageSelection(alteredProducts: [ProductReceipt]) {
        actions.append(RollbackAction(products: alteredProducts))
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