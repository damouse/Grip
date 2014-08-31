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
    
    
    init(packs: [Package], tableView: UITableView, selectBlock: (package: Package) -> Void) {
        packages = packs
        table = tableView
        didSelectBlock = selectBlock
        
        super.init()
        
        table.delegate = self
        table.dataSource = self
    }
    
    
    //MARK: Public Interface
    func highlighCellForPackage(package: Package) {
        //highlights the given cell in the given package
        let index = find(packages, package)
        
        //check for nil!
        
        let cell = table.cellForRowAtIndexPath(NSIndexPath(forRow: index!, inSection: 0)) as UITableViewCell
        cell.textLabel.textColor = HIGHLIGHT_COLOR
    }
    
    
    //MARK: UITableView Delegate
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel.text = packages[indexPath.row].name
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        didSelectBlock(package: packages[indexPath.row])
    }
}