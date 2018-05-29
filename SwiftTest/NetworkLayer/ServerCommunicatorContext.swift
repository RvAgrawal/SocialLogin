//
//  ServerCommunicatorContext.swift
//  Re-Deployment App
//
//  Created by tharani P on 15/09/17.
//  Copyright © 2017 tharani P. All rights reserved.
//

import Foundation

@objc
class ServerCommunicatorContext:NSObject {
    weak var parentDelegate:ServerCommunicatorDelegate?
    var contexterName:String?
    weak var downloadDelegate:NSObject?
    
    init(withParentDelegate parentDelegate:Any?, contexterName:String?, downloadDelegate:Any?) {
        self.parentDelegate = parentDelegate as? ServerCommunicatorDelegate
        self.downloadDelegate = downloadDelegate as? NSObject
        self.contexterName = contexterName
    }
    
    deinit {
        self.contexterName = nil
        self.downloadDelegate = nil
        self.parentDelegate = nil
    }
    
}
