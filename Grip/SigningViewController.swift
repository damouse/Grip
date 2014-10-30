//
//  SigningViewController.swift
//  Grip
//
//  Created by Mickey Barboi on 10/30/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import UIKit

class SigningViewController: UIViewController, UITableViewDataSource {
    //views
    @IBOutlet weak var scrollviewContent: UIScrollView!
    @IBOutlet weak var viewPage: UIView!
    
    //labels
    @IBOutlet weak var labelCustomerName: UILabel!
    @IBOutlet weak var labelMerchandise: UILabel!
    @IBOutlet weak var labelFinancing: UILabel!
    @IBOutlet weak var labelPayment: UILabel!

    @IBOutlet weak var labelSalesName: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelPackageName: UILabel!
    
    //Images
    @IBOutlet weak var imageCompanyLogo: UIImageView!
    @IBOutlet weak var imageGripLogo: UIImageView!
    
    //table
    @IBOutlet weak var tableProducts: UITableView!
    
    //External Variables
    var receipt : Receipt?
    
    
    //MARK: Boilerplate
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollviewContent.contentSize = self.viewPage.frame.size
        self.tableProducts.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        //populate labels
        labelCustomerName.text = self.receipt?.customer?.name
        labelMerchandise.text = self.receipt?.merchandise?.name
        labelFinancing.text = "\(self.receipt?.discount)%"
        labelPayment.text = "MONEY"
        
        labelSalesName.text = self.receipt?.user?.name
        labelPackageName.text = "PACKAGE NAME"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
        labelDate.text = dateFormatter.stringFromDate(NSDate())
        
        //colorze
        self.colorize()
    }

    func colorize() {
        
    }
    
    @IBAction func upload(sender: AnyObject) {
        self.uploadPDF()
    }
    
    func uploadPDF() {
        //create and upload the PDF
        let pdfFactory = PDFFactory()
        let uploader = S3FileManager()
        
        let data = pdfFactory.createPDFFromView(self.scrollviewContent)
        uploader.uploadFile(data, name: "test.pdf", completion: nil)
    }
    

    //MARK: Table delegate and Datasource
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.receipt!.productReceipts!.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:UITableViewCell? = self.tableProducts.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        let receipt = self.receipt!.productReceipts![indexPath.row]
        
        cell!.textLabel.text = receipt.name
        cell!.detailTextLabel.text = "\(receipt.price)"
        
        return cell
    }
}
