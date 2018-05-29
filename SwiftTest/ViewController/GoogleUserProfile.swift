//
//  GoogleUserProfile.swift
//  SwiftTest
//
//  Created by Ravi Agrawal on 23/05/18.
//  Copyright © 2018 Ravi Agrawal. All rights reserved.
//

import UIKit
import GoogleSignIn

protocol GoogleUserProfileDelegate {
    func didFinishWithGoogleUserDetails(userInfo : NSDictionary)
}

class GoogleUserProfile: NSObject,GIDSignInDelegate,GIDSignInUIDelegate{

    var vc : UIViewController?
    var delegate : GoogleUserProfileDelegate?
    
    func googleLogin(viewController : UIViewController) -> Void {
        
        self.vc = viewController
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if error !=  nil {
            print("\(error)")
        }
    }

    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.vc?.present(viewController, animated: true, completion: nil)
    }

    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.vc?.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            let dictUserInfo : NSDictionary = NSDictionary(objects: [userId!,idToken!,fullName!,givenName!,familyName!,email!], forKeys: ["userId" as NSCopying,"idToken" as NSCopying,"fullName" as NSCopying,"givenName" as NSCopying,"familyName" as NSCopying,"email" as NSCopying])
            
            if self.delegate != nil
            {
                self.delegate?.didFinishWithGoogleUserDetails(userInfo: dictUserInfo)
            }
            
            GIDSignIn.sharedInstance().signOut()
            
        } else {
            print("\(error)")
        }

    }
    
}
