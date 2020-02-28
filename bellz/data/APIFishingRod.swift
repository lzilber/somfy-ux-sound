//
//  APIFishingRod.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 20/01/2016.
//  Copyright © 2016 noion. All rights reserved.
//

import UIKit

class APIFishingRod: NSObject, URLSessionDelegate, FishingRod {
    
    let url: URL
    let trustedHost: Bool
    
    // Lazy init of the NSURLSession
    lazy var session: Foundation.URLSession = {
        [unowned self] in
        if self.trustedHost {
            return Foundation.URLSession(configuration: URLSessionConfiguration.default)
        } else {
            return Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        }
    }()
    
    init (_ string: String, trusted: Bool) {
        self.url = URL(string: string)!
        self.trustedHost = trusted
    }
    
    convenience init (_ string: String) {
        self.init(string, trusted: true)
    }
    
    // MARK: - Underlying plumbing
    
    struct RequestConstants {
        static let contentTypeHeader = "Content-Type"
    }

    fileprivate func jsonRequest(_ request: URLRequest, completion:@escaping (_ success: Bool, URLResponse?, NSError?, AnyObject?)  -> ()) {
        session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                if let error = error {
                    print("ERROR jsonRequest failed: \(error)")
                }
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    completion(true, response, error as NSError?,json as AnyObject?)
                } else {
                    print("WARNING \(String(describing: request.url)) \((response as! HTTPURLResponse).statusCode)")
                    print("ERROR \(json ?? "no json content with error message")")
                    completion(false, response, error as NSError?,json as AnyObject?)
                }
            }
            }) .resume()
    }
        
   /*
    * NSURLSessionDelegate handler for untrusted hosts.
    * Works if Info.plist also contains Apple ATS (App Transport Security) "Allow Arbitrary Loads" set to yes
    */
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func ping(_ completionHandler: ((Int)->())?) {
        let request = URLRequest(url: self.url)
        jsonRequest(request) { (success, response, error, json) -> () in
            if let response = response as? HTTPURLResponse , response.statusCode > 0 {
                completionHandler?(response.statusCode)
            } else {
                print(error?.userInfo ?? "WARNING ping failed")
                completionHandler?(0)
            }
        }
    }
    
    func requestURL(_ endPoint:String, _ method:String = "GET") -> URLRequest {
        var r = URLRequest(url: URL(string: "\(self.url)\(endPoint)")!)
        r.httpMethod = method
        return r
    }
    
    func jsonRequestURL(_ endPoint:String, _ method:String = "POST") -> URLRequest {
        var request = requestURL(endPoint, method)
        request.setValue("application/json", forHTTPHeaderField: RequestConstants.contentTypeHeader)
        return request
    }
    
    // MARK: - Login in and out
    
    func login(user userId:String, password userPassword:String, completionHandler: @escaping (Bool, AnyObject?)->()?) {
        var request = requestURL("/login", "POST")
        let parameters = "userId=\(userId)&userPassword=\(userPassword)"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: RequestConstants.contentTypeHeader)
        request.httpBody = parameters.data(using: String.Encoding.utf8)
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
    }
    
    func login(user userId:String, password userPassword:String) {
        login(user: userId, password: userPassword) { (success, json) -> ()? in
            return
        }
    }
    
    func logout(_ completionHandler: @escaping (Bool, AnyObject?)->()?) {
        let request = requestURL("/logout", "POST")
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
    }
    
    func logout() {
        logout { (success, json) -> ()? in
            return
        }
    }
    
    // MARK: - Setup
    
    func setup(_ completionHandler: @escaping (Bool, AnyObject?)->()?) {
        let request = requestURL("/setup")
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
        
    }

    func actionGroups(_ completionHandler: @escaping (Bool, AnyObject?)->()?) {
        let request = requestURL("/actionGroups")
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
    }
    
    func location(_ completionHandler: @escaping (Bool, AnyObject?)->()?) {
        let request = requestURL("/setup/location")
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
    }
    
    func updateLocation(json:Data, _ completionHandler: @escaping (Bool, AnyObject?)->()?) {
//        var request = jsonRequestURL("/setup/location", "PUT")
        var request = requestURL("/setup/location", "PUT")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = json
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
    }
    
    // MARK: - Actions

    func action(json:Data, _ completionHandler: @escaping (Bool, AnyObject?)->()?) {
        var request = jsonRequestURL("/exec/apply")
        request.httpBody = json
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
    }
    
    // MARK: - Events
    func startEvents(_ completionHandler: @escaping (Bool, AnyObject?)->()?) {
        let request = requestURL("/events/register", "POST")
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
    }

    func fetchEvents(listenerId: String, _ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        let request = requestURL("/events/\(listenerId)/fetch", "POST")
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
    }
    
    func stopEvents(listenerId: String, _ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        let request = requestURL("/events/\(listenerId)/unregister", "POST")
        jsonRequest(request) { (success, response, error, json) -> () in
            completionHandler(success, json)
        }
    }
    
    func stopEvents(listenerId: String) {
        stopEvents(listenerId: listenerId, { (success, json) -> ()? in
            return
        })
    }
}
