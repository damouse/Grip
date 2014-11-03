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
        
        UIGraphicsBeginPDFContextToData(rawData, CGRectMake(0.0, 0.0, 612, 792), nil)
        UIGraphicsBeginPDFPage()
        
        let context = UIGraphicsGetCurrentContext()
        let scale = CGFloat(0.4919614)
        CGContextScaleCTM(context, scale, scale)
        target.layer.renderInContext(context)
        UIGraphicsEndPDFContext()
        
        return rawData
    }

}