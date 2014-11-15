//
//  AccordionDescriptionTable.swift
//  Grip
//
//  Created by Mickey Barboi on 11/14/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
    Specific implementation of an accordion tableview for Grip description items
*/

import Foundation

class AccordionDescriptionTable : NSObject, UITableViewDataSource, UITableViewDelegate {
    var product: Product?
    var selectedIndex: NSIndexPath?
    
    //fixed heights used to size the cells
    let textviewWidth: Float = 401
    let videoHeight: Float = 200
    let titleViewHeight: Float = 67
    let seperatorHeight: Float = 3
    let padding: Float = 20
    
    var tableView: UITableView
    var details: [Detail]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    
    init(table: UITableView) {
        self.tableView = table
        
        super.init()
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        details = [Detail]()
    }
    
    func heightForRow(index: NSIndexPath) -> CGFloat {
        //calculate the height of the OPEN row based on the text size of the description text
        let detail = details![index.row]
        
        if detail.detail_type == "video" {
            return CGFloat(videoHeight + titleViewHeight)
        }
        
        let textfield = heightForTextview(detail)
        let height = textfield + CGFloat(titleViewHeight + seperatorHeight + padding)
        return height
    }
    
    func heightForTextview(detail: Detail) -> CGFloat {
        //return the height of a textview with a fixed width with a given attributed string
        let font = UIFont(name: "Titillium", size: 14)!
        let attributedString = NSMutableAttributedString(string: detail.description_text!, attributes:[NSFontAttributeName : font])
        
        let rect = attributedString.boundingRectWithSize(CGSizeMake(CGFloat(textviewWidth), CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return rect.size.height
    }
    
    func getVideoUrl(detail: Detail) -> String? {
        //get the video URL from the detail object. Check the type of the video first
        //returns nil if we don't know how to handle this video, else the YT string
        let ytBase = "https://www.youtube.com/watch?v="
        
        if detail.description_text!.rangeOfString(ytBase) != nil{
            
            return detail.description_text?.stringByReplacingOccurrencesOfString(ytBase, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        return nil
    }
    
    
    //MARK: UITableView Delegate and Datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedIndex != nil && indexPath == selectedIndex {
            return heightForRow(indexPath)
        }
        
        return CGFloat(titleViewHeight)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detail", forIndexPath: indexPath) as DetailsCell
        let detail = details![indexPath.row] as Detail
        
        cell.colorize()

        cell.labelTitle.text = detail.name?.uppercaseString
        cell.textviewDescription.text = detail.description_text
        
        //resize relevant views as needed
        cell.textviewDescription.frame.size = CGSizeMake(cell.textviewDescription.frame.size.width, heightForTextview(detail))
        cell.viewVideo.frame.size = CGSizeMake(cell.viewVideo.frame.size.width, CGFloat(videoHeight))
        
        if detail.detail_type == "video" {
            cell.showVideo(true, url: getVideoUrl(detail))
            cell.viewVideo.frame.size.height = CGFloat(videoHeight)
        }
        else {
            cell.showVideo(false, url: nil)
        }
        
        //custom seperators- should seperate the
        let sep = CALayer()
        sep.backgroundColor = PRIMARY_DARK.CGColor
        sep.frame = CGRectMake(0, 0, cell.frame.width, 3)
        cell.layer.addSublayer(sep)
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView .deselectRowAtIndexPath(indexPath, animated: false)
        let newCell = tableView.cellForRowAtIndexPath(indexPath) as DetailsCell
        
        if selectedIndex == nil {
            newCell.animateColor(true)
            selectedIndex = indexPath
        }
        else  {
            let oldCell = tableView.cellForRowAtIndexPath(selectedIndex!) as DetailsCell
            oldCell.animateColor(false)
            oldCell.viewVideo.pauseVideo()
            
            if selectedIndex != indexPath {
                newCell.animateColor(true)
                selectedIndex = indexPath
            }
            else {
                selectedIndex = nil
            }
        }
    
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if selectedIndex != nil {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
}