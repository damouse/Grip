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

    //remember-- need to set PDF margins to about 72pixels before uploading!
    func createPDFFromView(target: UIView) -> NSMutableData {
        var rawData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(rawData, CGRectMake(0.0, 0.0, 1024, 1768), nil)
        UIGraphicsBeginPDFPage()
        
        //incoming content is the correct dimensions, but is wrapped in a 100px buffed, so downsize
        //1968x1224
        let context = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(context, 0.62745, 0.62745)
        target.layer.renderInContext(context)
        UIGraphicsEndPDFContext()
        
        return rawData
    }

}