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
    @IBOutlet weak var viewButtonHolder: UIView!
    @IBOutlet weak var viewSignatureView: SignatureViewQuartzQuadratic!
    
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
    @IBOutlet weak var tableDeclined: UITableView!
    @IBOutlet weak var tableAccepted: UITableView!
    
    //Collections
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    //Signing Box
    @IBOutlet weak var labelHancock: UILabel!
    @IBOutlet weak var labelUnderline: UIView!
    
    
    //External Variables
    var receipt : Receipt?
    
    
    //Local Instance Variables
    var animator = MBViewAnimator(duration: ANIMATION_DURATION)
    var api: PGApiManager?
    
    var showingSignature = false
    
    var drawTableBlack = false
    
    
    
    //MARK: Boilerplate
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollviewContent.contentSize = self.viewPage.frame.size
        self.tableAccepted.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableDeclined.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        showingSignature = false
    }
    
    override func viewWillAppear(animated: Bool) {
        populateContent()
        setupAnimations()
        colorize()
    }
    
    override func viewDidAppear(animated: Bool) {
        initialAnimations()
    }

    func colorize() {
        view.backgroundColor = PRIMARY_LIGHT
        
        viewSignatureView.backgroundColor = PRIMARY_DARK
        viewButtonHolder.backgroundColor = PRIMARY_DARK
        
        for button in buttons {
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(HIGHLIGHT_COLOR, forState: UIControlState.Highlighted)
        }
    }
    
    func populateContent() {
        labelCustomerName.text = self.receipt?.customer?.name
        labelMerchandise.text = self.receipt!.merchandise_receipt_attributes?.name
        labelFinancing.text = "\(self.receipt!.discount)%"
        labelPayment.text = "\(self.receipt!.cost)";
        
        labelSalesName.text = self.receipt?.user?.name
        
        if self.receipt?.package == nil {
            labelPackageName.text = "Custome"
        }
        else {
            labelPackageName.text = self.receipt?.package?.name
        }
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
        labelDate.text = dateFormatter.stringFromDate(NSDate())
    }
    
    
    //MARK: Rendering, processing, and uploading-- The Money Methods
    func uploadReceipt() {
        //fetch API manager from the root controller-- no need to duplicate it
        //NOTE: singleton call! Creates a circular dependancy when importing the controller itself, only clean access
        let api = PGApiManager.sharedInstance
        
        let pdfView = renderPDFView()
        
        //upload API
        api.uploadReceipt(pdfView, superview: self.view, receipt: receipt!, completion: { (success: Bool) -> () in
            self.dismissController()
        })
    }
    
    func renderPDFView() -> UIView {
        //Flip the background color of the pdf view, add margins and spacing where needed, move the signature view to the bottom, 
        //and return the view
        
        //make the table reload its contents in black
        drawTableBlack = true
        tableDeclined.reloadData()
        tableAccepted.reloadData()
        
        viewPage.backgroundColor = UIColor.whiteColor()
        
        viewSignatureView.strokeColor = UIColor.blackColor()
        
        for label in labels {
            label.textColor = UIColor.blackColor()
        }
        
        viewSignatureView.removeFromSuperview()
        viewSignatureView.backgroundColor = UIColor.whiteColor()
        viewSignatureView.colorBlackAndWhite()
        labelHancock.textColor = UIColor.blackColor()
        labelUnderline.backgroundColor = UIColor.blackColor()
        viewPage.addSubview(viewSignatureView)
        
        let y = viewPage.frame.size.height - viewSignatureView.frame.size.height
        viewSignatureView.frame = CGRectMake(0, y, viewPage.frame.size.width, viewSignatureView.frame.size.height)
        
        //view as shown needs margins. Add them by adding the view to a superview with padding
        let enclosing = UIView(frame: CGRectMake(0, 0, viewPage.frame.size.width + 200, viewPage.frame.size.height + 200))
        
        enclosing.addSubview(viewPage)
        viewPage.frame.origin = CGPointMake(100, 100);
        
        return enclosing
    }

    func uploadReceiptModels() {
        //upload the receipt to the backend upon successful pdf transmission
    }
    
    
    //MARK: IBActions
    func initialAnimations() {
        //run the presentation animations
        animator.animateObjectOnscreen(viewButtonHolder, completion: nil)
    }
    
    func setupAnimations() {
        //set up the animations for this controller
        animator.initObject(viewSignatureView, inView: self.view, forSlideinAnimation: VAAnimationDirectionUp)
        animator.initObject(viewButtonHolder, inView: self.view, forSlideinAnimation: VAAnimationDirectionUp)
    }
    
    func teardownAnimations(completion: () -> Void) {
        //revert to a state where the controller can be dismissed
        animator.animateObjectOffscreen(viewSignatureView, completion: nil)
        animator.animateObjectOffscreen(viewButtonHolder, completion:  { (completed: Bool) -> Void in
            completion()
        })
    }
    
    
    //MARK: IBActions
    @IBAction func cancel(sender: AnyObject) {
        self.teardownAnimations({ () -> Void in
            self.navigationController!.popViewControllerAnimated(true)
            return
        })
    }
    
    @IBAction func confirm(sender: AnyObject) {
        if showingSignature {
            
            //this should not be here
            animator.animateObjectOffscreen(viewSignatureView, completion: nil)
            animator.animateObjectToStartingPosition(viewButtonHolder, completion: nil)
            
            uploadReceipt()
        }
        else {
            //not showing the signature view, present it
            let margin = view.frame.size.height - viewSignatureView.frame.size.height - viewButtonHolder.frame.size.height
            animator.animateObjectToRelativePosition(viewButtonHolder, direction: VAAnimationDirectionUp, withMargin: Int32(margin), completion: nil)
            animator.animateObjectOnscreen(viewSignatureView, completion: nil)
            
            showingSignature = true
        }
    }
    
    func dismissController() {
        self.teardownAnimations({ () -> Void in
            self.navigationController?.popToRootViewControllerAnimated(false)
            return
        })
    }
    

    //MARK: Table delegate and Datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableAccepted {
            return self.receipt!.product_receipts_attributes!.count
        }
        else {
            return self.receipt!.declinedProducts.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var productReceipt: ProductReceipt
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        if tableView == tableAccepted {
            productReceipt = self.receipt!.product_receipts_attributes![indexPath.row]
        }
        else {
            productReceipt = self.receipt!.declinedProducts[indexPath.row]
        }
        
        cell!.textLabel.text = productReceipt.name
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.roundingMode = NSNumberFormatterRoundingMode.RoundUp
        
        cell!.detailTextLabel!.text = "\(formatter.stringFromNumber(productReceipt.price)!)"
        
        cell?.backgroundColor = UIColor.clearColor()
        
        //set cell font programmatically
        cell!.textLabel.font = UIFont(name: "Titillium-Light", size: 20.0)
        cell!.detailTextLabel?.font = UIFont(name: "Titillium-Light", size: 15.0)
        
        if drawTableBlack {
            cell?.textLabel.textColor = UIColor.blackColor()
            cell?.detailTextLabel!.textColor = UIColor.blackColor()
        }
        else {
            cell?.textLabel.textColor = UIColor.whiteColor()
            cell?.detailTextLabel!.textColor = UIColor.whiteColor()
        }
        
        return cell!
    }
}
