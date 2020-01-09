//
//  EventManagerTests.swift
//  bellzTests
//
//  Created by Laurent ZILBER on 17/11/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import XCTest
@testable import bellz

class EventManagerTests: XCTestCase {

    var eventManager: EventManager?
    let testRod = DemoFishingRod("setupBoxLZ.txt")
    let testExecId = "test-execId"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        eventManager = EventManager(rod: testRod)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStart() {
        eventManager?.start()
        XCTAssertNotNil(eventManager?.listenerId)
    }

    func testStop() {
        eventManager?.start()
        XCTAssertNotNil(eventManager?.listenerId)
        eventManager?.stop()
        XCTAssertNil(eventManager?.listenerId)
    }

    func testStopNotStarted() {
        eventManager?.stop()
        XCTAssertNil(eventManager?.listenerId)
    }
    
    func testSubscribe() {
        eventManager?.start()
        XCTAssertTrue((eventManager?.subscribe(eventId: testExecId))!)
        XCTAssertFalse((eventManager?.subscribe(eventId: testExecId))!)
        eventManager?.stop()
    }

    func testUnsubscribe() {
        eventManager?.start()
        XCTAssertFalse((eventManager?.unsubscribe(eventId: testExecId))!)
        XCTAssertTrue((eventManager?.subscribe(eventId: testExecId))!)
        XCTAssertTrue((eventManager?.unsubscribe(eventId: testExecId))!)
        eventManager?.stop()
    }

    func testUpdate() {
        eventManager?.start()
        XCTAssertTrue((eventManager?.subscribe(eventId: testExecId))!)
        XCTAssertTrue((eventManager?.update())!)
        eventManager?.stop()
    }

    func testEventClass() {
        let data = """
               [
                   {
                       "timestamp": 1574413248137,
                       "setupOID": "SETUP-0123-4567-8910",
                       "execId": "\(testExecId)",
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
                       "timestamp": 1574413248137,
                       "gatewayId": "0123-4567-8910",
                       "name": "GatewaySynchronizationStartedEvent"
                   }
               ]
               """.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        for eventData in json as! [AnyObject] {
            let event:Event = Event()
            do {
                try? event.from(eventData)
            }
        }
    }
    
    func testGatewaySynchronizationEvent() {
        let data = """
                   {
                       "timestamp": 1574413248137,
                       "gatewayId": "0123-4567-8910",
                       "name": "GatewaySynchronizationStartedEvent"
                   }
               """.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        let event = GatewaySynchronizationEvent()
        try? event.from(json as AnyObject)
        XCTAssertTrue(event.gatewayId == "0123-4567-8910")
    }
    
    func testExecutionRegisteredEvent() {
        let data = """
                   {
                       "timestamp": 1574413248137,
                       "setupOID": "SETUP-0123-4567-8910",
                       "execId": "\(testExecId)",
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
                   }
               """.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        let event = ExecutionRegisteredEvent()
        try? event.from(json as AnyObject)
        XCTAssertTrue(event.execId == testExecId)
    }
    
    func testExecutionStateChangedEvent() {
        let data = """
           {
               "timestamp": 1574413248138,
               "setupOID": "SETUP-0123-4567-8910",
               "execId": "\(testExecId)",
               "newState": "FAILED",
               "ownerKey": "SETUP-0123-4567-8910",
               "type": 1,
               "subType": 1,
               "oldState": "NOT_TRANSMITTED",
               "timeToNextState": -1,
               "failedCommands": [
                   {
                       "deviceURL": "zigbee://0123-4567-8910/12345/1#1",
                       "rank": 0,
                       "failureType": "PEER_DOWN"
                   }
               ],
               "failureTypeCode": 10005,
               "name": "ExecutionStateChangedEvent",
               "failureType": "PEER_DOWN"
           }
        """.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        let event = ExecutionStateChangedEvent()
        try? event.from(json as AnyObject)
        XCTAssertTrue(event.execId == testExecId, "Expected \(testExecId), got \(event.execId)")
    }
}
