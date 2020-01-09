//
//  FishingRod.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 24/02/2018.
//  Copyright © 2018 noion. All rights reserved.
//

import Foundation

protocol FishingRod {
    func ping(_ completionHandler: ((Int)->())?)
    func login(user userId:String, password userPassword:String, completionHandler: @escaping (Bool, AnyObject?)->()?)
    func login(user userId:String, password userPassword:String)
    func logout(_ completionHandler: @escaping (Bool, AnyObject?)->()?)
    func logout()
    func setup(_ completionHandler: @escaping (Bool, AnyObject?)->()?)
    func actionGroups(_ completionHandler: @escaping (Bool, AnyObject?)->()?)
    func location(_ completionHandler: @escaping (Bool, AnyObject?)->()?)
    func updateLocation(json:Data, _ completionHandler: @escaping (Bool, AnyObject?)->()?)
    func action(json:Data, _ completionHandler: @escaping (Bool, AnyObject?)->()?)
    func startEvents(_ completionHandler: @escaping (Bool, AnyObject?)->()?)
    func fetchEvents(listenerId: String, _ completionHandler: @escaping (Bool, AnyObject?)->()?)
    func stopEvents(listenerId: String)
}

class DemoFishingRod: NSObject, FishingRod {
    
    var setupURL: URL?
    
    init(_ setupFile:String ) {
        let fileparts = setupFile.components(separatedBy: ".")
        if fileparts.count == 2 {
            setupURL = Bundle.main.url(forResource: fileparts[0], withExtension: fileparts[1])
        } else {
            print("ERROR : setup file name \(setupFile) cannot be split")
        }
    }
    
    func ping(_ completionHandler: ((Int) -> ())?) {
        print("Ping called")
    }
    
    func login(user userId: String, password userPassword: String, completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        completionHandler(true, nil)
    }
    
    func login(user userId: String, password userPassword: String) {
        login(user: userId, password: userPassword) { (success, json) -> ()? in
            return
        }
    }
    
    func logout(_ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        completionHandler(true, nil)
    }
    
    func logout() {
        logout { (success, json) -> ()? in
            return
        }
    }
    
    func setup(_ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        // Load JSon from file
        let jsonData = try? Data(contentsOf: setupURL!)
        if let data = jsonData {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            completionHandler(true, json as AnyObject?)
        } else {
            completionHandler(false, nil)
        }
    }
    
    func actionGroups(_ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        print("TODO actionGroups")

    }
    
    func location(_ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        print("TODO location")

    }
    
    func updateLocation(json: Data, _ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        print("TODO updateLocation")

    }
    
    func action(json: Data, _ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        let s:String = String(data:json, encoding:.utf8)!
        print("DEBUG ActionGtroup json is \(s)")
        completionHandler(true, nil)
    }
 
    func startEvents(_ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        let data = """
        {
            "id": "92533b43-7f00-0101-1811-4814d35df53d"
        }
        """.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        completionHandler(true, json as AnyObject?)
    }

    func fetchEvents(listenerId: String, _ completionHandler: @escaping (Bool, AnyObject?) -> ()?) {
        let timestamp = Date().timeIntervalSince1970
        let data = """
        [
            {
                "timestamp": \(timestamp),
                "setupOID": "SETUP-0123-4567-8910",
                "execId": "test-execId",
                "label": "on on zigbee:OnOffComponent",
                "metadata": "",
                "type": 1,
                "subType": 1,
                "triggerId": "",
                "actions": [
                    {
                        "deviceURL": "zigbee://0123-4567-8910/12345/1#1",
                        "commands": [
                            {
                                "name": "on"
                            }
                        ]
                    }
                ],
                "name": "ExecutionRegisteredEvent"
            },
            {
                "timestamp": \(timestamp),
                "gatewayId": "0123-4567-8910",
                "name": "GatewaySynchronizationStartedEvent"
            }
        ]
        """.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        completionHandler(true, json as AnyObject?)    }
    
    func stopEvents(listenerId: String) {
        // Nothing to do
        return
    }
}
