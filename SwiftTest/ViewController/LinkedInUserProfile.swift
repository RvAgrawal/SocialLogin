//
//  LinkedInUserProfile.swift
//  SwiftTest
//
//  Created by Ravi Agrawal on 23/05/18.
//  Copyright © 2018 Ravi Agrawal. All rights reserved.
//

import UIKit
import LinkedinSwift

protocol LinkedInUserProfileDelegate {
    func didFinishLinkedInuserProfile(userInfo : NSDictionary)
}

class LinkedInUserProfile: NSObject {

    var delegate : LinkedInUserProfileDelegate?
    
    func linkedInLogin(viewController : UIViewController) -> Void {
        
        let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: "81x6pcr3u2zatb", clientSecret: "k9023rrj4gWMk1mc", state: "DCEEFWF45453sdffef424", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl: "https://com.social.linkedin.oauth/oauth"))
        
        linkedinHelper.authorizeSuccess({ (lsToken) -> Void in
            //Login success lsToken
            print("Token : \(lsToken)")
            
            linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,maiden-name,email-address,picture-url,formattedName)?format=json",
                                      requestType: LinkedinSwiftRequestGet,
                                      success: { (response) -> Void in
                                        //Request success response
                                        print(response.jsonObject)
                                        
                                        //check conditions for all the fields
                                        
                                        let dictUserInfo = NSDictionary(objects: [response.jsonObject["lastName"]!,response.jsonObject["firstName"]!,response.jsonObject["id"]!,response.jsonObject["formattedName"]!,response.jsonObject["pictureUrl"]!,response.jsonObject["emailAddress"]!], forKeys: ["lastName" as NSCopying,"firstName" as NSCopying,"id" as NSCopying,"formattedName" as NSCopying,"pictureUrl" as NSCopying,"emailAddress" as NSCopying])
                                        
                                        if self.delegate != nil
                                        {
                                            self.delegate?.didFinishLinkedInuserProfile(userInfo: dictUserInfo)
                                        }
                                        
            })  { (error) -> Void in
                
                //Encounter error
            }
            
        }, error: { (error) -> Void in
            //Encounter error: error.localizedDescription
            print(error.localizedDescription)
        }, cancel: { () -> Void in
            //User Cancelled!
            print("Canceled operation")
        })
    }
    
    func shareOnLinkedin(viewController : UIViewController) -> Void {
//        let url: String = "https://api.linkedin.com/v1/people/~/shares"
//
//        let payloadStr: String = "{\"comment\":\"YOUR_APP_LINK_OR_WHATEVER_YOU_WANT_TO_SHARE\",\"visibility\":{\"code\":\"anyone\"}}"
//
//        let payloadData = payloadStr.data(using: String.Encoding.utf8)
//
//        let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: "81x6pcr3u2zatb", clientSecret: "k9023rrj4gWMk1mc", state: "DCEEFWF45453sdffef424", permissions:
//            ["r_basicprofile", "r_emailaddress"], redirectUrl: "https://com.social.linkedin.oauth/oauth"))
//
//        Link.sharedInstance().postRequest(url, body: payloadData, success: { (response) in
//
//            print(response!.data)
//
//        }, error: { (error) in
//
//            print(error as! Error)
//
//            let alert = UIAlertController(title: "Alert!", message: "something went wrong", preferredStyle: .alert)
//            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//
//            alert.addAction(action)
//            self.present(alert, animated: true, completion: nil)
//
//
//        })
    }
    
}
