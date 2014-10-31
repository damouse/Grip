//
//  S3FileManager.swift
//  Grip
//
//  Created by Mickey Barboi on 10/29/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class S3FileManager : NSObject {
    let debugLog = false
    
    override init () {
    }
    
    
    //MARK: Public Methods
    func uploadFile(file: NSMutableData, name: String, completion: ((success: Bool) -> ())?) {
        //save the file as temp, form the request, and send it off through the AWS conenction manager
        let fileURL = self.saveFileToURL(file)
        let request = self.createUploadRequest(fileURL, name: name)
        
        
        self.startRequest(request, completion)
    }
    
    
    //MARK: Internal Methods
    func saveFileToURL(file: NSMutableData) -> NSURL {
        let temp = NSTemporaryDirectory()
        let fileURL = NSURL.fileURLWithPath(temp.stringByAppendingPathComponent("temp.pdf"))
        
        var error: NSError?
        file.writeToURL(fileURL, atomically:false)
        return fileURL
    }
    
    func createUploadRequest(url: NSURL, name: String) -> AWSS3TransferManagerUploadRequest {
        let request = AWSS3TransferManagerUploadRequest()
        request.bucket = "grippdf"
        request.key = name
        request.body = url
        request.uploadProgress = { (sent: Int64, total: Int64, expected: Int64) -> Void in
            if self.debugLog {
                println("AWS: Sent \(total) of \(expected)")
            }
        }
        
        return request
    }
    
    func startRequest(request: AWSS3TransferManagerUploadRequest, completion: ((success: Bool) -> ())?) {
        let manager = AWSS3TransferManager.defaultS3TransferManager()
        manager.upload(request).continueWithBlock( { (task: BFTask!) -> BFTask in
            
            if let err = task.error {
                println("AWS: Error occured. \(err)")
                completion?(success:false)
            }
            else {
                println("AWS: Uploaded file successfully")
                if completion != nil {
                    completion?(success:true)
                }
            }
            
            return BFTask()
        })
    }
}