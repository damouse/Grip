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
    
    let textviewWidth: Float = 401.0
    
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
    
    func heightForRow() {
        //calculate the height of the row based on the text size of the description text
        
    }
    
    func heightForTextview(string: String, detail: Detail) -> CGFloat {
        //return the height of a textview with a fixed width with a given attributed string
        let font = UIFont(name: "Titillium", size: 14)!
        let attributedString = NSMutableAttributedString(string: detail.description_text!, attributes:[NSFontAttributeName : font])
        
        let rect = attributedString.boundingRectWithSize(CGSizeMake(CGFloat(textviewWidth), CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return rect.size.height
    }
    
    /*
    - (CGSize)calculateHeightForString:(NSString *)str
    {
    CGSize size = CGSizeZero;
    
    UIFont *labelFont = [UIFont systemFontOfSize:17.0f];
    NSDictionary *systemFontAttrDict = [NSDictionary dictionaryWithObject:labelFont forKey:NSFontAttributeName];
    
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:str attributes:systemFontAttrDict];
    CGRect rect = [message boundingRectWithSize:(CGSize){320, MAXFLOAT}
    options:NSStringDrawingUsesLineFragmentOrigin
    context:nil];//you need to specify the some width, height will be calculated
    size = CGSizeMake(rect.size.width, rect.size.height + 5); //padding
    
    return size;
    
    
    }
    */
    
    //MARK: UITableView Delegate and Datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let detail = details![indexPath.row] as Detail?
        
        if selectedIndex != nil && indexPath == selectedIndex {
            return 200
        }
        
        return 67
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detail", forIndexPath: indexPath) as DetailsCell
        let detail = details![indexPath.row] as Detail
        
        cell.colorize()

        cell.labelTitle.text = detail.name?.uppercaseString
        cell.textviewDescription.text = detail.description_text
        
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