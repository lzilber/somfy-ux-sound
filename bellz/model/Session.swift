//
//  Session.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 11/02/2016.
//  Copyright © 2016 noion. All rights reserved.
//
import UIKit
import Combine

open class Session : ObservableObject {
    
    static let loginSuccess = Notification.Name("LoginSuccess")
    static let loginFailed  = Notification.Name("LoginFailed")
    static let logout  = Notification.Name("SessionLogout")
    static let setupUpdated = Notification.Name("SetupUpdated")
    static let executeActionGroup = Notification.Name("executeActionGroup")

    enum SessionError: Error {
        case uninitialized
        case unauthenticated
    }
    
    var rod:FishingRod?
    var eventManager:EventManager?

    // User Session info
    @Published var selectedServer: ServerURL = ServerURL.default
    @Published var authenticated: Bool = false
    @Published var didShowVictory: Bool = false
    @Published var soundEnabled: Bool = false{
        didSet {
            if soundEnabled {
                Jukebox.instance.playHighNote()
            }
        }
    }
    var isDemo:Bool = false

    var currentUsername:String = "?"
    
    // Model
    @Published var setup:Setup = Setup()
    var actionGroups: [ActionGroup] = []
    
    static let demoSession: Session = {
        let session = Session()
        session.openDemo()
        return session
    } ()

    // MARK: - API
    public func open(username: String, password: String, serverURL: ServerURL = .default) {

        selectedServer = serverURL
        self.rod = APIFishingRod(selectedServer.url, trusted: false)
        self.eventManager = EventManager(rod: self.rod!)

        if let rod = self.rod {
            rod.login(user: username, password: password, completionHandler: { (success, result) -> () in
                if success {
                    self.authenticated = true
                    self.currentUsername = username
                    NotificationCenter.default.post(name: Session.loginSuccess, object: self)
                    self.load()
                } else {
                    print("WARNING login failed for '\(username)': ")
                    print(result ?? "result unavailable")
                    guard let json = result as? [String: AnyObject] else {
                        NotificationCenter.default.post(name: Session.loginFailed, object: self, userInfo: ["error":"Unknown error"])
                        return
                    }
                    NotificationCenter.default.post(name: Session.loginFailed, object: self, userInfo: json)
                }
            })
        } else {
            print("ERROR No FishingRod: cannot login()")
        }
    }
    
    
    public func openDemo() {
        self.rod = DemoFishingRod("setupBoxLZ.txt")
        self.eventManager = EventManager(rod: self.rod!)
        self.authenticated = true
        self.currentUsername = "Demo"
        self.isDemo = true
        NotificationCenter.default.post(name: Session.loginSuccess, object: self)
        self.load()
    }
        
    
    // Use for Log Out
    open func close() {
        if let rod = self.rod {
            rod.logout({ (success, result) -> () in
                if success {
                    NotificationCenter.default.post(name: Session.logout, object: self)
                    self.flush()
                    self.currentUsername = ""
                    self.authenticated = false
                } else {
                    print("WARNING logout failed: ")
                    print(result ?? "result unavailable")
                }
            })
        } else {
            print("ERROR No FishingRod: cannot logout()")
        }
    }
    
    open func flush() {
        print("INFO Session flushed")
        self.setup = Setup()
        self.actionGroups = []
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "SessionSetupUpdated"), object: self)
    }
    
    open func refreshLocation() {
        guard (self.rod != nil) else {
            return
        }
        self.rod!.location() { (success, jsonData) -> () in
            do {
                try self.setup.location.from(jsonData!)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SessionLocationUpdated"), object: self)
            } catch JSONCompatibleError.invalidJSONData {
                print("ERROR Failed to load setup (invalidJSONData)")
            } catch JSONCompatibleError.invalidField(let field) {
                print("ERROR Failed to load setup (invalid field \(field))")
            } catch JSONCompatibleError.missingField(let field) {
                print("ERROR Failed to load setup (missing field \(field))")
            } catch {
                print("ERROR Failed to load setup")
            }
        }
    }
    
    open func execute(command deviceCommand: DeviceCommand, on device:Device, p1: String = "", p2: String = "") {
        
        // Build ActionGroup
        let actionCommand:ActionCommand = ActionCommand(command: deviceCommand, p1: p1, p2: p2)
        let action = Action(deviceUrl: device.deviceURL, command: actionCommand)
        let group = ActionGroup("\(deviceCommand.name) on \(device.controllableName)", action:action)
        let data:Data = group.toJson()
        
        // Run
        self.rod!.action(json: data, { (success, result) -> () in
            if success {
                print("DEBUG actionCommand success ! \(String(describing: result))")
                NotificationCenter.default.post(name: Session.executeActionGroup, object: self, userInfo: ["error":""])
                // Subscribe for Event
                if let data = result as? [String: AnyObject] {
                    do {
                        let execId = try JSONUtils.string("execId", json: data)
                        if !(self.eventManager?.subscribe(eventId: execId))! {
                            print("ERROR Failed to subscribe to execId event")
                        }
                    } catch {
                        print("ERROR Failed to parse execId from actionCommand result")
                    }
                }
            } else {
                print("ERROR failed to send Command: ")
                print(result ?? "result unavailable")
                guard let json = result as? [String: AnyObject] else {
                    NotificationCenter.default.post(name: Session.executeActionGroup, object: self, userInfo: ["error":"Unknown error"])
                    return
                }
                NotificationCenter.default.post(name: Session.executeActionGroup, object: self, userInfo: json)
            }
        })
    }
    
    // MARK: - internal
    
    private func load() {
        guard (self.rod != nil) else {
            print("ERROR No FishingRod: cannot load()")
            return
        }
        flush()
        self.rod!.setup() { (success, jsonData) -> () in
            do {
                try self.setup.from(jsonData!)
                // print("DEBUG Setup loaded...")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SessionSetupUpdated"), object: self)
            } catch JSONCompatibleError.invalidJSONData {
                print("ERROR Failed to load setup (invalidJSONData)")
            } catch JSONCompatibleError.invalidField(let field) {
                print("ERROR Failed to load setup (invalid field \(field))")
            } catch JSONCompatibleError.missingField(let field) {
                print("ERROR Failed to load setup (missing field \(field))")
            } catch {
                print("ERROR Failed to load setup")
            }
        }

        self.rod!.actionGroups { (success, jsonData) -> () in
            do {
                for agData in jsonData as! [AnyObject] {
                    var ag:ActionGroup = ActionGroup()
                    do {
                        try ag.from(agData)
                        self.actionGroups.append(ag)
                    }
                }
            } catch JSONCompatibleError.invalidJSONData {
                print("ERROR Failed to load setup (invalidJSONData)")
            } catch JSONCompatibleError.invalidField(let field) {
                print("ERROR Failed to load setup (invalid field \(field))")
            } catch JSONCompatibleError.missingField(let field) {
                print("ERROR Failed to load setup (missing field \(field))")
            } catch {
                print("ERROR Failed to load setup")
            }
        }
    }
}



