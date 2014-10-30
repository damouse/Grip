//
//  PDFFactory.swift
//  Grip
//
//  Created by Mickey Barboi on 10/22/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

//Class that creates PDF documents from a view. Includes options to email them for debugging purposes

import Foundation
import MessageUI

class PDFFactory : NSObject {
    var parent: UIViewController?
    var pdfData: NSMutableData?
//    override init() {
//        
//    }

    func createPDFFromView(target: UIView) -> NSMutableData {
        var rawData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(rawData, CGRectMake(0.0, 0.0, 792.0, 612.0), nil)
        UIGraphicsBeginPDFPage()
        let context = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(context, 1, 1)
        target.layer.renderInContext(context)
        UIGraphicsEndPDFContext()
        
        return rawData
//        self.pdfData = rawData
        
//        UIView* testView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
//        NSMutableData* pdfData = [NSMutableData data];
//        UIGraphicsBeginPDFContextToData(pdfData, CGRectMake(0.0f, 0.0f, 792.0f, 612.0f), nil);
//        UIGraphicsBeginPDFPage();
//        CGContextRef pdfContext = UIGraphicsGetCurrentContext();
//        CGContextScaleCTM(pdfContext, 0.773f, 0.773f);
//        [testView.layer renderInContext:pdfContext];
//        UIGraphicsEndPDFContext();
    }
    
    //////
    // IMPORTED CODE
    //////
//    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
//        switch result.value {
//        case MFMailComposeResultCancelled.value:
//            NSLog("Mail cancelled")
//        case MFMailComposeResultSaved.value:
//            NSLog("Mail saved")
//        case MFMailComposeResultSent.value:
//            NSLog("Mail sent")
//        case MFMailComposeResultFailed.value:
//            NSLog("Mail sent failure: %@", [error.localizedDescription])
//        default:
//            break
//        }
//        
//        parent?.dismissViewControllerAnimated(false, completion: nil)
//    }
//    
//    func showEmail() {
//        if MFMailComposeViewController.canSendMail() {
//            var emailTitle = "Test Email"
//            var messageBody = "This is a test email body"
//            var toRecipents = ["damouse007@gmail.com"]
//    //        var mc: MFMailComposeViewController = MFMailComposeViewController()
//            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//            var mc = appDelegate.mailComposer
//            
//            mc.mailComposeDelegate = self
//            mc.setSubject(emailTitle)
//            mc.setMessageBody(messageBody, isHTML: false)
//            mc.setToRecipients(toRecipents)
//            mc.addAttachmentData(self.pdfData, mimeType: "application/pdf", fileName: "test.pdf")
//            
//            parent?.presentViewController(mc, animated: true, completion: nil)
//        }
//        else {
//            print("Cannot send mail!")
//        }
//    }

}