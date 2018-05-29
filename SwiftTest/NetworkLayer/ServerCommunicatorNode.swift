//
//  ServerCommunicatorNode.swift
//  Re-Deployment App
//
//  Created by tharani P on 15/09/17.
//  Copyright © 2017 tharani P. All rights reserved.
//

import Foundation
@objc
protocol ServerCommunicatorNodeDelegate {
    func serverCommunicator(communicatorNode:ServerCommunicatorNode, didDownload data:Any, inContexter:ServerCommunicatorContext?)
    func serverCommunicator(communicatorNode:ServerCommunicatorNode, didFailedToDownloadWith error:Any?, inContexter:ServerCommunicatorContext?)
    func serverCommunicator(communicatorNode:ServerCommunicatorNode, didProgressTo progress:Float, inContexter:ServerCommunicatorContext?)
}

class ServerCommunicatorNode:NSObject, URLSessionDataDelegate, URLSessionDelegate {
    var urlString:String?
    var contexter:ServerCommunicatorContext?
    weak var delegate:ServerCommunicatorNodeDelegate?
    var  downloadData : Data?
    var  jsonString:String?
    var  body:Any?
    var  method :Any?
    var  header :Any?
    var  data:Any?
    var uploadData:Any?
    var urlRequest : URLRequest?
    var dataTask:URLSessionDataTask?
    var uploadTask:URLSessionUploadTask?
    var contentType:String?
    var filePathUrl:URL?
    var includeToken:Bool = true

    init(with urlString:String, responseDelegate delegate:Any?, contexter:ServerCommunicatorContext) {
        self.urlString = urlString
        self.delegate = delegate as? ServerCommunicatorNodeDelegate
        self.contexter = contexter
        self.downloadData = Data()
    }
    
    init(with urlString:String, responseDelegate delegate:Any?,body:Dictionary<String,Any>, contexter:ServerCommunicatorContext) {
        self.urlString = urlString
        self.delegate = delegate as? ServerCommunicatorNodeDelegate
        self.contexter = contexter
        self.downloadData = Data()
        self.body = body
    }
    
    init(with urlString:String, responseDelegate delegate:Any?, body:Dictionary<String,Any>?, method:Any, contexter:ServerCommunicatorContext) {
        self.urlString = urlString
        self.delegate = delegate as? ServerCommunicatorNodeDelegate
        self.contexter = contexter
        self.downloadData = Data()
        self.body = body
        self.method = method
    }
    
    init(with urlString:String, responseDelegate delegate:Any?,bodyInArray:Array<Any>, contexter:ServerCommunicatorContext) {
        self.urlString = urlString
        self.delegate = delegate as? ServerCommunicatorNodeDelegate
        self.contexter = contexter
        self.downloadData = Data()
        self.body = bodyInArray
    }
    
    init(uploadNodeWith urlString:String, responseDelegate delegate:Any?, uploadData:Data?, bodyInArray:Array<Any>?, contexter:ServerCommunicatorContext, method:String, contentType:String?, fileUrl url: URL?) {
        self.urlString = urlString
        self.delegate = delegate as? ServerCommunicatorNodeDelegate
        self.contexter = contexter
        if let data = uploadData {
            self.uploadData = data
        }
        self.method = method
        self.downloadData = Data()
        if let body = bodyInArray {
            self.body = body
        }
        if let conType = contentType {
            self.contentType = conType
        }
        if let fileUrl = url {
            self.filePathUrl = fileUrl
        }
    }
    
    deinit {
        self.urlString = nil
        self.delegate  = nil
        self.contexter = nil
        self.downloadData = nil
        self.body = nil
        self.method = nil
        self.jsonString = nil
        self.header = nil
        self.uploadData = nil
        self.filePathUrl = nil
    }
    
    func cleanUp() {
        self.urlString = nil
        self.delegate  = nil
        self.contexter = nil
        self.downloadData = nil
        self.body = nil
        self.method = nil
        self.jsonString = nil
        self.header = nil
        self.urlRequest = nil
        self.dataTask = nil
        self.data = nil
        self.uploadTask = nil
    }
    
    func checkExpirationTimeIsValid() -> Bool {
        let futureExpiryTime = Date()
        let expires_in_date  = UserDefaults.standard.value(forKey: "expires_in") as? Date
        if let compareDate = expires_in_date  {
                if futureExpiryTime <= compareDate {
                    return true
                }
        }
        return false
    }
    
    
    func makeAPICall() {
        print("Token not expired")
        guard self.urlString != nil else { return }
        let urlLink = URL(string: self.urlString!)
        if let link = urlLink {
            self.urlRequest = URLRequest(url: link)
            if (body != nil) {
                do {
                    let jsonData : Data = try JSONSerialization.data(withJSONObject: body!, options: .prettyPrinted)
                    jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                    let bodyData: Data? = jsonString?.data(using: String.Encoding.utf8)
                    if(bodyData != nil ) {
                        urlRequest?.httpBody = bodyData
                    }
                } catch {
                    
                }
            }
            if header == nil {
                if UserDefaults.standard.value(forKey: "access_token") != nil {
                    urlRequest?.setValue("bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
                }
            }
        
            //START HEADER
            let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
            if let version = nsObject as? String {
                urlRequest?.setValue(version, forHTTPHeaderField: "app_version")
            }
            
//            urlRequest?.setValue(Constants.platform, forHTTPHeaderField: "platform")
//            urlRequest?.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: "os_version")
//            urlRequest?.setValue(UIDevice.current.model, forHTTPHeaderField: "device_model")
//            urlRequest?.setValue(Constants.device_brand, forHTTPHeaderField: "device_brand")
//            urlRequest?.setValue(UIDevice.current.identifierForVendor?.uuidString, forHTTPHeaderField: "device_id")
            if let accessToken = UserDefaults.standard.value(forKey: "access_token") as? String {
                urlRequest?.setValue(accessToken, forHTTPHeaderField: "access_token")
            }
            //END HEADER
            
            if method != nil {
                urlRequest?.httpMethod = self.method as? String
            } else {
                urlRequest?.httpMethod = "POST"
            }
            urlRequest?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60
            let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
            if let req = self.urlRequest {
                self.dataTask = urlSession.dataTask(with: req)
                self.dataTask?.resume()
            }
        } else {
            self.delegate?.serverCommunicator(communicatorNode: self, didFailedToDownloadWith: nil, inContexter: self.contexter)
        }
    }
    
    func startDownload() {
        if includeToken {
            if checkExpirationTimeIsValid() {
                self.makeAPICall()
            } else {
                print("Token expired")
//                self.generateRefreshToken()
            }
        } else {
             self.makeAPICall()
        }
    }
    
    func startUploadData() {
        if let url = self.urlString {
            let urlLink = URL(string: url)
            self.urlRequest = URLRequest(url: urlLink!)
            if let data = self.uploadData as? Data {
                urlRequest?.httpBody = data
            }
            if header == nil {
                if UserDefaults.standard.value(forKey: "access_token") != nil {
                    urlRequest?.setValue("bearer \(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "Authorization")
                }
            }
            if UserDefaults.standard.value(forKey: "access_token") != nil {
                urlRequest?.setValue("\(UserDefaults.standard.value(forKey: "access_token")!)", forHTTPHeaderField: "access_token")
            }
     
            if method != nil {
                urlRequest?.httpMethod = self.method as? String
            } else {
                urlRequest?.httpMethod = "POST"
            }
            
            if let contentType = self.contentType {
                urlRequest?.setValue(contentType,forHTTPHeaderField: "Content-Type")
            }
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60
            let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
            if let req = self.urlRequest ,let _ = self.uploadData as? Data, let _ = self.contentType {
                self.uploadTask = urlSession.uploadTask(withStreamedRequest: req)
                self.uploadTask?.resume()
                /* working code
                 self.dataTask = urlSession.dataTask(with: req)
                 self.dataTask?.resume()
                 */
            }
        }
    }
    
    //MARK: Data task delegate
    //MARK: Data task delegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let _ = self.uploadTask {
            let progress = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
            self.delegate?.serverCommunicator(communicatorNode: self, didProgressTo: Float(progress), inContexter: self.contexter)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let response = dataTask.response
        self.downloadData?.append(data)
        if(response != nil ) {
            let expectedLength = response?.expectedContentLength
            if(expectedLength != nil) {
                if(expectedLength! > 0) {
                    let currentDataLength = dataTask.countOfBytesReceived
                    let progress = currentDataLength / expectedLength!
                    self.delegate?.serverCommunicator(communicatorNode: self, didProgressTo: Float(progress), inContexter: self.contexter)
                }
            }
        }
    }
    
    func saveUserCredentialsFrom(httpResponse:HTTPURLResponse) {
        if let token = httpResponse.allHeaderFields["access_token"] as? String {
            UserDefaults.standard.setValue(token, forKey: "access_token")
        }
        if let refreshToken = httpResponse.allHeaderFields["refresh_token"] as? String {
            UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")
        }
        if let expires_in = httpResponse.allHeaderFields["expires_in"] as? String {
            if let expiration = TimeInterval(expires_in) {
                let saveDate = Date.init(timeInterval: expiration, since: Date())
                UserDefaults.standard.set(saveDate, forKey: "expires_in")
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        var statusCode : Int = 0
        if task.response != nil {
            if let code = (task.response as? HTTPURLResponse)?.statusCode {
                statusCode = code
            }
        }
        if statusCode == 401 {
            generateRefreshToken()
        }
        else {
            let response = task.response
            if let httpResponse = response as? HTTPURLResponse {
                self.saveUserCredentialsFrom(httpResponse: httpResponse)
            }
            do {
                self.data = try JSONSerialization.jsonObject(with: self.downloadData!, options: .allowFragments)
                self.delegate?.serverCommunicator(communicatorNode: self, didDownload: self.data , inContexter: self.contexter)
            } catch {
                self.delegate?.serverCommunicator(communicatorNode: self, didFailedToDownloadWith: nil, inContexter: self.contexter)
            }
        }
        if(error != nil) {
            self.delegate?.serverCommunicator(communicatorNode: self, didFailedToDownloadWith: error, inContexter: self.contexter)
        }
    }
    
    //MARK: Instance Methods
    
//    func generateRefreshToken() {
//        let session = URLSession.shared
//        let baseUrl = Constants.baseUrl
//        let hostPath = URL(string: "\(baseUrl)") ///profile/refreshtoken
//        let aHostPath = hostPath?.deletingLastPathComponent()
//        let aHostPathRemove = aHostPath?.deletingLastPathComponent()
//        let validPath = aHostPathRemove?.appendingPathComponent("token")
//        if let aHost = validPath {
//            var request = URLRequest(url: aHost)
//            let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
//            if let version = nsObject as? String {
//                request.setValue(version, forHTTPHeaderField: "app_version")
//            }
////            request.setValue(Constants.platform, forHTTPHeaderField: "platform")
////            request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: "os_version")
////            request.setValue(UIDevice.current.model, forHTTPHeaderField: "device_model")
////            request.setValue(Constants.device_brand, forHTTPHeaderField: "device_brand")
////            request.setValue(UIDevice.current.identifierForVendor?.uuidString, forHTTPHeaderField: "device_id")
//            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//            request.httpMethod = "POST"
//            if let refreshToken = UserDefaults.standard.value(forKey: "refresh_token") as? String {
//                if refreshToken.count > 0 {
//                    do {
//                        let jsonStr  =  "grant_type=refresh_token&refresh_token=\(refreshToken)"
//                        let aBodyData: Data? = jsonStr.data(using: String.Encoding.utf8)
//                        if(aBodyData != nil ) {
//                            request.httpBody = aBodyData
//                            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
//                                do {
//                                    if let aData = data {
//                                        let data = try JSONSerialization.jsonObject(with: aData, options: .allowFragments)
//                                        if let aResponse = data as? NSDictionary {
//
//                                            if let aToken = aResponse["access_token"] {
//                                                UserDefaults.standard.setValue(aToken, forKey: "access_token")
//                                            }
//                                            if let aRef_token = aResponse["refresh_token"] {
//                                                UserDefaults.standard.setValue(aRef_token, forKey: "refresh_token")
//                                            }
//                                            if let expires_in = aResponse["expires_in"] as? Int {
//                                                let expiration = TimeInterval(expires_in)
//                                                let saveDate = Date.init(timeInterval: expiration, since: Date())
//                                                UserDefaults.standard.set(saveDate, forKey: "expires_in")
//                                            }
//                                            if let _ = aResponse["error"] {
//                                                self.removeAccessTokenAndNavigateToHomeScreen()
//                                            }
//                                        } else {
//                                            self.showLoginScreen()
//                                        }
//                                    } else {
//                                        //show home screen
//                                        self.removeAccessTokenAndNavigateToHomeScreen()
//                                    }
//                                } catch {
//                                    //show home screen
//                                    self.removeAccessTokenAndNavigateToHomeScreen()
//                                }
//                            })
//                            task.resume()
//                        }
//                    } catch {
//                        //show home screen
//                        self.removeAccessTokenAndNavigateToHomeScreen()
//                    }
//                } else {
//                    self.showLoginScreen()
//                }
//            } else {
//                self.showLoginScreen()
//            }
//        }
//    }
    
//    func removeAccessTokenAndNavigateToHomeScreen() {
//        UserDefaults.standard.removeObject(forKey: "access_token")
//        UserDefaults.standard.removeObject(forKey: "expires_in")
//        UserDefaults.standard.synchronize()
//        self.showLoginScreen()
//    }
    
//    func showLoginScreen() {
//        DispatchQueue.main.async {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.removeLoaderHandler()
//            let application = UIApplication.shared
//            if let _ = appDelegate.window?.rootViewController as? ViewController {
//                //it showing the login view controller ... :)
//            } else {
//                if let window = application.keyWindow {
//                    let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                    let initialViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
//                        let appDeleagte = UIApplication.shared.delegate as? AppDelegate
//                        if let applicationDelegate = appDeleagte {
//                            applicationDelegate.window?.rootViewController = initialViewController
//                        }
//                    }, completion: { completed in
//
//                    })
//                }
//            }
//        }
//    }
    
}
