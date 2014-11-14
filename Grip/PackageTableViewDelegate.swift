//
//  PackageTableViewDelegate.swift
//  Grip
//
//  Created by Mickey Barboi on 8/29/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation


class PackageTableViewDelegate : NSObject, UITableViewDataSource, UITableViewDelegate {
    var packages: [Package]
    var table: UITableView
    var didSelectBlock: ((package: Package) -> Void)
    
    //the currently selected cell
    var selectedCell: UITableViewCell?
    
    
    init(packs: [Package], tableView: UITableView, selectBlock: (package: Package) -> Void) {
        packages = packs
        table = tableView
        didSelectBlock = selectBlock
        
        super.init()
        
        table.delegate = self
        table.dataSource = self
    }
    
    
    //MARK: Public Interface
    func highlighCellForPackage(package: Package?) -> Bool {
        //if nil passed in, then the user has selected a product that makes the packages not match to anything
        if package == nil {
            
            //if selected cell is not nil, package is selected that needs to be unselected
            if selectedCell != nil {
                selectedCell!.textLabel.textColor = UIColor.whiteColor();
            }
            
            return false
        }
        
        let index = find(packages, package!)
        
        //if package not found, this package is not meant for us. Deselect the active packge if one exists
        if index == nil {
            if selectedCell != nil {
                selectedCell!.textLabel.textColor = UIColor.whiteColor();
            }
            
            return false
        }
        
        var cell = table.cellForRowAtIndexPath(NSIndexPath(forRow: index!, inSection: 0))!
        cell.textLabel.textColor = HIGHLIGHT_COLOR
        
        //if another cell was previously selected, deselect it
        if selectedCell != nil {
            if cell != selectedCell {
                selectedCell!.textLabel.textColor = UIColor.whiteColor();
            }
        }
        
        selectedCell = cell
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel.text = packages[indexPath.row].name
        cell.backgroundColor = UIColor.clearColor()
        
        cell.textLabel.font = UIFont(name: "Titillium-Light", size: 20.0)
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        didSelectBlock(package: packages[indexPath.row] as Package)
    }
}