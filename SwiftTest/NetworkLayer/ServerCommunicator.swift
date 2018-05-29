//
//  ServerCommunicator.swift
//  Re-Deployment App
//
//  Created by tharani P on 15/09/17.
//  Copyright © 2017 tharani P. All rights reserved.d.
//

//This calss is responsible for communication with server instead of backendless and perform some n/w operation.

import Foundation
import UIKit
@objc
protocol ServerCommunicatorDelegate {
    func serverCommunicator(communicator:ServerCommunicator, didGet response:Any?, inContext:ServerCommunicatorContext?)
    func serverCommunicator(communicator:ServerCommunicator, didFailedWith error:Any?, inContext:ServerCommunicatorContext?)
    func serverCommunicator(communicator:ServerCommunicator, progressTo progress:CGFloat, inContext:ServerCommunicatorContext?)
}


final class  ServerCommunicator:NSObject , ServerCommunicatorNodeDelegate {
    
    //Singleton
    static let shared = ServerCommunicator()
    private override init() {  }
    
    func downloadData(From inURLString:String , parentDelegate theDelegate:Any?, theContext  context:ServerCommunicatorContext) { //theDelegate is alerady set in contexter so no need to set hear
        let aDownloadNode = ServerCommunicatorNode(with: inURLString, responseDelegate: self, contexter: context)
        aDownloadNode.startDownload()
    }
    
    func downloadData(from inUrlSting:String, body :Any ,parentDelegate theDelegate:Any?, theContext  context:ServerCommunicatorContext, includeToken:Bool) {
        let aDownloadNode = ServerCommunicatorNode(with: inUrlSting, responseDelegate: self, body: body as! Dictionary<String, Any>, contexter: context)
        aDownloadNode.includeToken = includeToken
        aDownloadNode.startDownload()
    }
    
    func downloadData(from inUrlSting:String, body :Any ,parentDelegate theDelegate:Any?, theContext  context:ServerCommunicatorContext) {
        let aDownloadNode = ServerCommunicatorNode(with: inUrlSting, responseDelegate: self, body: body as! Dictionary<String, Any>, contexter: context)
        aDownloadNode.startDownload()
    }   
    
    func downloadData(from inUrlSting:String, body :Any?, method : String, parentDelegate theDelegate:Any?, theContext  context:ServerCommunicatorContext, includeToken:Bool) {
        let aDownloadNode = ServerCommunicatorNode(with: inUrlSting, responseDelegate: self, body: body as? Dictionary<String, Any> , method: method, contexter: context)
        aDownloadNode.includeToken = includeToken
        aDownloadNode.startDownload()
    }

    func downloadData(from inUrlSting:String, body :Any?, method : String, parentDelegate theDelegate:Any?, theContext  context:ServerCommunicatorContext) {
        let aDownloadNode = ServerCommunicatorNode(with: inUrlSting, responseDelegate: self, body: body as? Dictionary<String, Any> , method: method, contexter: context)
        aDownloadNode.startDownload()
    }
    
    func serverCommunicator(communicatorNode:ServerCommunicatorNode, didDownload data:Any, inContexter:ServerCommunicatorContext?) {
        guard let parentDelegate = inContexter?.parentDelegate else { return }
        parentDelegate.serverCommunicator(communicator: self, didGet: data, inContext: inContexter)
        communicatorNode.cleanUp()
    }
    
    func serverCommunicator(communicatorNode:ServerCommunicatorNode, didFailedToDownloadWith error:Any?, inContexter:ServerCommunicatorContext?) {
        guard let parentDelegate = inContexter?.parentDelegate else { return }
        parentDelegate.serverCommunicator(communicator: self, didFailedWith: error, inContext: inContexter)
        communicatorNode.cleanUp()
    }
    
    func serverCommunicator(communicatorNode:ServerCommunicatorNode, didProgressTo progress:Float, inContexter:ServerCommunicatorContext?) {
        guard let parentDelegate = inContexter?.parentDelegate else { return }
        parentDelegate.serverCommunicator(communicator: self, progressTo: CGFloat(progress), inContext: inContexter)
    }
    
    func downloadData(from inUrlSting:String, bodyInArray :Any?, method : String, parentDelegate theDelegate:Any?, theContext  context:ServerCommunicatorContext) {
        let aDownloadNode = ServerCommunicatorNode(with: inUrlSting, responseDelegate: self, bodyInArray: bodyInArray as! Array<Any>, contexter: context)
        aDownloadNode.startDownload()
    }
    
    func uploadData(from inUrlSting:String, bodyInArray :Any?, uploadData data:Any?, method : String, parentDelegate theDelegate:Any?, theContext  context:ServerCommunicatorContext, contentType:String?, fileUrl url:URL?) {
        let aUploadNode = ServerCommunicatorNode(uploadNodeWith: inUrlSting, responseDelegate: self, uploadData: data as? Data, bodyInArray: bodyInArray as? Array<Any>, contexter: context, method:method, contentType:contentType, fileUrl: url)
        aUploadNode.startUploadData()
    }
    

}
