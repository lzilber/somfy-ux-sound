//
//  EventManager.swift
//  bellz
//
//  Created by Laurent ZILBER on 16/11/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import Foundation
import Combine

class EventManager {
    
    static let executionStateChanged = Notification.Name("executionStateChanged")

    /*
     let currentTimePublisher  = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .common)
     .autoconnect()
     
     */
//    let timePublisher  = Timer.TimerPublisher(interval: 3.0, runLoop: .main, mode: .common).autoconnect()
    static let updateInterval:TimeInterval = 3
    var timer : Timer!
    
    var rod: FishingRod
    var listenerId: String?
    var subscribedIds = [String]()
    
    init(rod: FishingRod) {
        self.rod = rod
        
    }
    
    func start() {
        rod.startEvents() { (success, json) -> () in
            if success {
                if let data = json as? [String: AnyObject] {
                    do {
                        try self.listenerId = JSONUtils.string("id", json: data)
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(withTimeInterval: EventManager.updateInterval, repeats: true)
                        { _ in
                            _ = self.update()
                        }
                        print("DEBUG \(Date()) EventManager started")
                    } catch {
                        print("ERROR Failed to parse listenerId for EventManager")
                    }
                }
            } else {
                print("ERROR Failed to get listenerId for EventManager")
            }
        }
    }
        
    func subscribe(eventId: String) -> Bool {
        if !subscribedIds.contains(eventId) {
            subscribedIds.append(eventId)
//            if self.listenerId == nil {
//                start()
//            }
            return true
        }
        return false
    }
    
    func unsubscribe(eventId: String) -> Bool {
        if let index = subscribedIds.firstIndex(of: eventId) {
            subscribedIds.remove(at: index)
//            if subscribedIds.count == 0 {
//                return stop()
//            }
            return true
        }
        print("ERROR eventId not found: did you subscribe()?")
        return false
    }

    func update() -> Bool {
        //print("DEBUG running update()")
        guard let lid = listenerId else {
            print("ERROR listenerId not set: did you start() the EventManager?")
            return false
        }
        rod.fetchEvents(listenerId: lid) { (success, json) -> () in
            if success {
                do {
                    for eventData in json as! [AnyObject] {
                        let event:Event = Event()
                        do {
                            try event.from(eventData)
                            switch event.name {
                            case .GatewaySynchronizationStarted, .GatewaySynchronizationEnded, .GatewaySynchronizationFailed:
                                let gatewayEvent = GatewaySynchronizationEvent()
                                try gatewayEvent.from(eventData)
                                print("DEBUG (unused) Got \(gatewayEvent.name) for \(gatewayEvent.gatewayId)")
                            case .ExecutionRegistered:
                                let executionEvent = ExecutionRegisteredEvent()
                                try executionEvent.from(eventData)
                                print("DEBUG (unused) Got \(executionEvent.name) for \(executionEvent.execId)")
                            case .ExecutionStateChanged:
                                let executionEvent = ExecutionStateChangedEvent()
                                try executionEvent.from(eventData)
                                print("BINGO !! Got \(executionEvent.name) : \(executionEvent.oldState) -> \(executionEvent.newState)")
                                if self.subscribedIds.contains(executionEvent.execId) {
                                    NotificationCenter.default.post(name: EventManager.executionStateChanged, object: self, userInfo: ["state":executionEvent.newState])
                                }

                            default:
                                print("FIXME Event \(event.name) is not handled")
                            }
                        }
                    }
                } catch JSONCompatibleError.invalidJSONData {
                    print("ERROR Failed to load events (invalidJSONData)")
                } catch JSONCompatibleError.invalidField(let field) {
                    print("ERROR Failed to load events (invalid field \(field))")
                } catch JSONCompatibleError.missingField(let field) {
                    print("ERROR Failed to load events (missing field \(field))")
                } catch {
                    print("ERROR Failed to load Events in eventManager")
                }
            } else {
                print("ERROR Failed to get listenerId for EventManager")
            }
        }
        return true
    }
        
    func stop() {
        guard let lid = listenerId else {
            print("DEBUG listenerId not set: did you start() the EventManager?")
            return
        }
        rod.stopEvents(listenerId: lid)
        self.timer?.invalidate()
        self.listenerId = nil
        print("DEBUG \(Date()) EventManager stopped")
    }
    
//    var timer : Timer!
//    let didChange = PassthroughSubject<TimerHolder,Never>()
//    var count = 0 {
//        didSet {
//            self.didChange.send(self)
//        }
//    }
//    func start() {
//        self.timer?.invalidate()
//        self.count = 0
//        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
//            _ in
//            self.count += 1
//        }
//    }
}
