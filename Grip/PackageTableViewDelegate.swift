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
    var didSelectBlock: ((package: Package) -> Void)?
    
    
    init(packs: [Package], tableView: UITableView) {
        packages = packs
        table = tableView
        
        super.init()
        
        table.delegate = self
        table.dataSource = self
    }
    
    
    //MARK: UITableView Delegate
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel.text = packages[indexPath.row].name
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        didSelectBlock!(package: packages[indexPath.row])
    }
}