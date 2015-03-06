//
//  HTTPHelper.swift
//  Selfie
//
//  Created by Subhransu Behera on 18/11/14.
//  Copyright (c) 2014 subhb.org. All rights reserved.
//

import Foundation

enum HTTPRequestAuthType {
    case HTTPBasicAuth
    case HTTPTokenAuth
}

enum HTTPRequestContentType {
    case HTTPJsonContent
    case HTTPMultipartContent
}

struct HTTPHelper {
    static let API_AUTH_NAME = "BITIRME"
    static let API_AUTH_PASSWORD = "yrfafyqteweaqsddteefqddqfwrtysfrqreqqeafyrtssftayrsrrqetytyeefqr"
    //static let BASE_URL = "https://gentle-stream-7806.herokuapp.com/api"
    static let BASE_URL = "http://127.0.0.1:3000/api"
    
    func buildRequest(path: String!, method: String, authType: HTTPRequestAuthType,
        requestContentType: HTTPRequestContentType = HTTPRequestContentType.HTTPJsonContent, requestBoundary:NSString = "") -> NSMutableURLRequest {
            // 1. Create the request URL from path
            let requestURL = NSURL(string: "\(HTTPHelper.BASE_URL)/\(path)")
            var request = NSMutableURLRequest(URL: requestURL!)
            
            // Set HTTP request method and Content-Type
            request.HTTPMethod = method
            
            // 2. Set the correct Content-Type for the HTTP Request. This will be multipart/form-data for photo upload request and application/json for other requests in this app
            switch requestContentType {
            case .HTTPJsonContent:
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            case .HTTPMultipartContent:
                let contentType = NSString(format: "multipart/form-data; boundary=%@", requestBoundary)
                request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            }
            
            // 3. Set the correct Authorization header.
            switch authType {
            case .HTTPBasicAuth:
                // Set BASIC authentication header
                let basicAuthString = "\(HTTPHelper.API_AUTH_NAME):\(HTTPHelper.API_AUTH_PASSWORD)"
                let utf8str = basicAuthString.dataUsingEncoding(NSUTF8StringEncoding)
                let base64EncodedString = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
                
                request.addValue("Basic \(base64EncodedString!)", forHTTPHeaderField: "Authorization")
            case .HTTPTokenAuth:
                // Retreieve Auth_Token from Keychain
                let userToken : NSString? = KeychainAccess.passwordForAccount("Auth_Token", service: "KeyChainService")
                // Set Authorization header
                request.addValue("Token token=\(userToken!)", forHTTPHeaderField: "Authorization")
            }
            
            return request
    }
    
    
    func sendRequest(request: NSURLRequest, completion:(NSData!, NSError!) -> Void) -> () {
        // Create a NSURLSession task
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(data, error)
                })
                
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let httpResponse = response as NSHTTPURLResponse
                
                if httpResponse.statusCode == 200 {
                    completion(data, nil)
                } else {
                    var jsonerror:NSError?
                    let errorDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as NSDictionary
                    
                    let responseError : NSError = NSError(domain: "HTTPHelperError", code: httpResponse.statusCode, userInfo: errorDict)
                    completion(data, responseError)
                }
            })
        }
        
        // start the task
        task.resume()
    }
    func getErrorMessage(error: NSError) -> NSString {
        var errorMessage : NSString
        
        // return correct error message
        if error.domain == "HTTPHelperError" {
            let userInfo = error.userInfo as NSDictionary!
            errorMessage = userInfo.valueForKey("message") as NSString
        } else {
            errorMessage = error.description
        }
        
        return errorMessage
    }
}