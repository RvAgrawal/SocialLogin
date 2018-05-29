//
//  FacebookUserProfile.swift
//  SwiftTest
//
//  Created by Ravi Agrawal on 23/05/18.
//  Copyright © 2018 Ravi Agrawal. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FacebookShare

protocol FacebookUserProfileDelegate {
    func didFinishWithUserProfile(userProfile : NSDictionary)
}

class FacebookUserProfile: NSObject {
    
    var delegate : FacebookUserProfileDelegate?

    func facebookLogin(viewController : UIViewController) -> Void {
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.email,.publicProfile], viewController: viewController) { loginResult in
            
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in! Granted Permissions : \(grantedPermissions) & Declined Permissions : \(declinedPermissions) & Access Token :\(accessToken)")
                self.fetchUserProfile()
            }
        }
        
        loginManager.logOut()
    }
    
    // MARK :  - Get Facebook user details
    
    func fetchUserProfile()
    {
        let request = GraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, gender, picture,id"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(let value):
                let dictUserInfo : NSDictionary = value.dictionaryValue! as NSDictionary
                
                if self.delegate != nil
                {
                    self.delegate?.didFinishWithUserProfile(userProfile: dictUserInfo)
                }
                
            case .failed(let error):
                print(error)
            }
        }
    }
    
    
    // MARK : - Facebook Sharing
    
    //If facebook app is available
    func shareContentOnFacebook(viewController : UIViewController) -> Void {
        
        var content = LinkShareContent(url: URL(string: "http://example.com")!,
                                       title: "Title",
                                       description: "Description",
                                       imageURL: URL(string: "http://test.com/test.png"))
        
        let shareDialog = ShareDialog(content: content)
        shareDialog.mode = .native
        shareDialog.failsOnInvalidData = true
        shareDialog.completion = { result in
            // Handle share results
        }
        
        do{
            try shareDialog.show()
        }catch{
            
        }
    }
}
