//
//  ViewController.swift
//  SwiftTest
//
//  Created by Ravi Agrawal on 15/05/18.
//  Copyright © 2018 Ravi Agrawal. All rights reserved.
//

import UIKit
//import FacebookCore
//import FacebookLogin
//import LinkedinSwift
import GoogleSignIn
import TwitterKit

class ViewController: UIViewController,FacebookUserProfileDelegate,LinkedInUserProfileDelegate,GIDSignInDelegate,GIDSignInUIDelegate {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnFacebookLoginAction(_ sender: UIButton) {
        
        self.indicator.startAnimating()
        
        let facebookUserProfile = FacebookUserProfile()
        facebookUserProfile.delegate = self
        
        facebookUserProfile.facebookLogin(viewController: self)
        
        
    }
    
    func didFinishWithUserProfile(userProfile: NSDictionary) {
        self.indicator.stopAnimating()
        print(userProfile)
    }
    
    
    
    
    @IBAction func btnLinkedinLoginAction(_ sender: Any) {
        
        self.indicator.startAnimating()
        
        let linkedinUserProfile = LinkedInUserProfile()
        linkedinUserProfile.delegate = self
        
        linkedinUserProfile.linkedInLogin(viewController: self)
    }
    
    func didFinishLinkedInuserProfile(userInfo: NSDictionary) {
        self.indicator.stopAnimating()
        print(userInfo)
    }
    
    
    
    @IBAction func btnTwitterAction(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                print("User Name \(String(describing: session?.userName))");
                print("User Id \(String(describing: session?.userID))");
                print("AuthToken \(String(describing: session?.authToken))");
                
                let oauthSigning = TWTROAuthSigning.init(authConfig: TWTRTwitter.sharedInstance().authConfig, authSession: session!)
                let oauthHeaders : NSDictionary = oauthSigning.oAuthEchoHeadersToVerifyCredentials() as NSDictionary
                
                let oauthParameters = Array(oauthHeaders)[1].value
                let urlString = Array(oauthHeaders)[0].value
                
                let url = URL(string: urlString as! String)
                let request = NSMutableURLRequest(url: url as! URL)
                
                request.allHTTPHeaderFields = ["Authorization":oauthParameters] as? [String : String]
                request.httpMethod = "GET"
                
                let session = URLSession.shared
                let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                    print("Response: \(String(describing: response))")
                    print(String(data: data!, encoding: .utf8)!)
                })
                
                
                task.resume()
                
                
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
    }
    
    
    
    @IBAction func btnGooglePlusAction(_ sender: Any) {
        
//        self.indicator.startAnimating()
//
//        let googleUserProfile = GoogleUserProfile()
//        googleUserProfile.delegate = self
//
//        googleUserProfile.googleLogin(viewController: self)
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().signIn()
    }

//    func didFinishWithGoogleUserDetails(userInfo: NSDictionary) {
//        self.indicator.stopAnimating()
//        print(userInfo)
//    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if error !=  nil {
            print("\(error)")
        }
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            let profilepic = user.profile.imageURL(withDimension: 150)
            
            let dictUserInfo : NSDictionary = NSDictionary(objects: [userId!,idToken!,fullName!,givenName!,familyName!,email!,profilepic!], forKeys: ["userId" as NSCopying,"idToken" as NSCopying,"fullName" as NSCopying,"givenName" as NSCopying,"familyName" as NSCopying,"email" as NSCopying,"profilepic" as NSCopying])
            
            print(dictUserInfo)
            
//            if self.delegate != nil
//            {
//                self.delegate?.didFinishWithGoogleUserDetails(userInfo: dictUserInfo)
//            }
            
            GIDSignIn.sharedInstance().signOut()
            
        } else {
            print("\(error)")
        }
        
    }
    
    
    
    // MARK : Sharing Functionality
    
    @IBAction func btnFbShareAction(_ sender: Any) {
        
        let facebookUserProfile = FacebookUserProfile()
        facebookUserProfile.delegate = self
        
        facebookUserProfile.shareContentOnFacebook(viewController: self)
    }
    
}

