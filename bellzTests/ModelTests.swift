//
//  ModelTests.swift
//  bellzTests
//
//  Created by Laurent ZILBER on 15/01/2020.
//  Copyright © 2020 zebre.org. All rights reserved.
//

import XCTest
@testable import bellz

class ModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGateway() {
        var objectToTest = Gateway()
        let valueToTest = "1234-5678-9100"
        let rawDefinition = """
            {
              "gatewayId": "\(valueToTest)",
              "type": 29,
              "subType": 1,
              "placeOID": "placeOID-1234-5678-9100",
              "alive": true,
              "timeReliable": true,
              "connectivity": {
                "status": "OK",
                "protocolVersion": "23"
              },
              "upToDate": true,
              "syncInProgress": false,
              "mode": "ACTIVE",
              "functions": "INTERNET_AUTHORIZATION,SCENARIO_DOWNLOAD,SCENARIO_AUTO_LAUNCHING,SCENARIO_TELECO_LAUNCHING,INTERNET_UPLOAD,INTERNET_UPDATE,TRIGGERS_SENSORS"
            }
        """
        let data = rawDefinition.data(using: .utf8)!
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            try objectToTest.from(json as AnyObject)
            XCTAssert(objectToTest.gatewayId == valueToTest)
        } catch JSONCompatibleError.invalidJSONData {
            XCTFail("ERROR: invalidJSONData")
        } catch JSONCompatibleError.invalidField(let field) {
            XCTFail("ERROR: invalid field \(field))")
        } catch JSONCompatibleError.missingField(let field) {
            XCTFail("ERROR: missing field \(field))")
        } catch {
            XCTFail("ERROR: \(error.localizedDescription)")
        }
    }
    
    func testDeviceDefinition() {
        var objectToTest = DeviceDefinition()
        let valueToTest = "testUIClass"
        let rawDefinition = """
            {
              "commands": [
                {
                  "commandName": "aCommand",
                  "nparams": 0
                },
                {
                  "commandName": "anotherCommand",
                  "nparams": 1
                },
                {
                  "commandName": "someTestCommand",
                  "nparams": 2
                }
              ],
              "states": [
                {
                  "type": "ContinuousState",
                  "qualifiedName": "core:aContinuousState"
                },
                {
                  "type": "DataState",
                  "qualifiedName": "core:sDataState"
                },
                {
                  "values": [
                    "false",
                    "true"
                  ],
                  "type": "DiscreteState",
                  "qualifiedName": "internal:ADiscreteState"
                }
              ],
              "dataProperties": [],
              "widgetName": "TestWidgetName",
              "uiClass": "\(valueToTest)",
              "qualifiedName": "internal:TestQualifiedName",
              "type": "ACTUATOR"
            }
        """
        let data = rawDefinition.data(using: .utf8)!
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            try objectToTest.from(json as AnyObject)
            XCTAssert(objectToTest.uiClass == valueToTest)
        } catch JSONCompatibleError.invalidJSONData {
            XCTFail("ERROR Failed to parse deviceDefinition (invalidJSONData)")
        } catch JSONCompatibleError.invalidField(let field) {
            XCTFail("ERROR Failed to parse deviceDefinition (invalid field \(field))")
        } catch JSONCompatibleError.missingField(let field) {
            XCTFail("ERROR Failed to parse deviceDefinition (missing field \(field))")
        } catch {
            XCTFail("ERROR Failed to parse deviceDefinition : \(error.localizedDescription)")
        }
    }

    func testLocation() {
        var objectToTest = Location()
        let valueToTest = "Spain"
        let rawDefinition = """
           {
             "creationTime": 1491835289000,
             "lastUpdateTime": 1503924206000,
             "city" : "Barcelona",
             "country" : "\(valueToTest)",
             "postalCode" : "123456",
             "addressLine1" : "Test address line1",
             "addressLine2" : "Test address line2",
             "timezone": "Europe/Paris",
             "longitude": 6.125665774982675,
             "latitude": 45.91989886348042,
             "twilightMode": 2,
             "twilightAngle": "CIVIL",
             "twilightCity": "paris",
             "summerSolsticeDuskMinutes": 1290,
             "winterSolsticeDuskMinutes": 990,
             "twilightOffsetEnabled": false,
             "dawnOffset": 0,
             "duskOffset": 0
           }
        """
        let data = rawDefinition.data(using: .utf8)!
        do {
            var json = try JSONSerialization.jsonObject(with: data, options: [])
            try objectToTest.from(json as AnyObject)
            XCTAssert(objectToTest.country == valueToTest)
            // Test toJson
            let generatedData = objectToTest.toJson()
            json = try JSONSerialization.jsonObject(with: generatedData, options: [])
            try objectToTest.from(json as AnyObject)
            XCTAssert(objectToTest.country == valueToTest)
        } catch JSONCompatibleError.invalidJSONData {
                           XCTFail("ERROR Failed to parse location (invalidJSONData)")
                       } catch JSONCompatibleError.invalidField(let field) {
                           XCTFail("ERROR Failed to parse location (invalid field \(field))")
                       } catch JSONCompatibleError.missingField(let field) {
                           XCTFail("ERROR Failed to parse location (missing field \(field))")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testActionGroup() {
        var objectToTest = ActionGroup()
        let valueToTest = "test label actionGroup"
        let rawDefinition = """
            {
                "creationTime": 1560419964000,
                "lastUpdateTime": 1560419964000,
                "label": "\(valueToTest)",
                "metadata": "",
                "shortcut": false,
                "notificationTypeMask": 0,
                "notificationCondition": "NEVER",
                "actions": [
                    {
                        "deviceURL": "zigbee://1234-5678-9100/1234/1",
                        "commands": [
                            {
                                "type": 1,
                                "name": "sendOpaqueCommand",
                                "parameters": [
                                    0,
                                    "wP/uur4="
                                ]
                            },
                            {
                                "type": 1,
                                "name": "sendOpaqueCommand",
                                "parameters": [
                                    0,
                                    "wP/uur4="
                                ]
                            }
                        ]
                    }
                ],
                "oid": "actiongroupOID-1234-5678-9100"
            }
        """
        let data = rawDefinition.data(using: .utf8)!
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            try objectToTest.from(json as AnyObject)
            XCTAssert(objectToTest.label == valueToTest)
            XCTAssert(objectToTest.actions[0].commands.count == 2, "Expecting 2 commands in the first action of this test ActionGroup")
        } catch JSONCompatibleError.invalidJSONData {
            XCTFail("ERROR: invalidJSONData")
        } catch JSONCompatibleError.invalidField(let field) {
            XCTFail("ERROR: invalid field \(field))")
        } catch JSONCompatibleError.missingField(let field) {
            XCTFail("ERROR: missing field \(field))")
        } catch {
            XCTFail("ERROR: \(error.localizedDescription)")
        }

    }

}
