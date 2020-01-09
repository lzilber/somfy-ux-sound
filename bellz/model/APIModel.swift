//
//  APIModel.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 11/02/2016.
//  Copyright © 2016 noion. All rights reserved.
//

import Foundation

enum JSONCompatibleError: Error {
    case invalidJSONData
    case missingField(fieldName:String)
    case invalidField(fieldName:String)
}

protocol JSONCompatible {
    mutating func from(_ jsonData: AnyObject) throws
    var rawString: String { get }
}

/** Provides fields for display, usually in a tableView cell.
 */
protocol Displayable {
    var title: String { get }
    var detail: String { get }
}

class JSONUtils {

    static func string(_ key:String, json:[String: AnyObject]) throws -> String {
        guard let stringValue:AnyObject = json[key] else {
            throw JSONCompatibleError.missingField(fieldName: key)
        }
        return stringValue as! String
    }

    static func int(_ key:String, json:[String: AnyObject]) throws -> Int {
        guard let intValue:AnyObject = json[key] else {
            throw JSONCompatibleError.missingField(fieldName: key)
        }
        return intValue as! Int
    }
    
    static func float(_ key:String, json:[String: AnyObject]) throws -> Float {
        guard let number:NSNumber = json[key] as? NSNumber else {
            throw JSONCompatibleError.missingField(fieldName: key)
        }
        return number.floatValue
    }
    
    static func bool(_ key:String, json:[String: AnyObject]) throws -> Bool {
        guard let boolValue:AnyObject = json[key] else {
            throw JSONCompatibleError.missingField(fieldName: key)
        }
        return boolValue as! Bool
    }
    
    static func timestamp(_ key:String, json:[String: AnyObject]) throws -> Date {
        guard let dateValue:AnyObject = json[key] else {
            throw JSONCompatibleError.missingField(fieldName: key)
        }
        return TimeUtils.dateFromTimeIntervalSince1970(dateValue as! Double)
    }
}

class TimeUtils {
    static func dateFromTimeIntervalSince1970(_ milliseconds:Double) -> Date {
        let seconds = milliseconds/1000
        return Date(timeIntervalSince1970: seconds)
    }
    
    static func timestampSeconds(_ date:Date) -> UInt {
        let now = date.timeIntervalSince1970
        if now > 0 {
            return UInt(now)
        } else {
            return 0
        }
    }
    
    static func timestampMilliSecs(_ date:Date) -> UInt {
        let now = (date.timeIntervalSince1970 * 1000)
        if now > 0 {
            return UInt(now)
        } else {
            return 0
        }
    }
}


public struct Gateway : JSONCompatible {
    var gatewayId: String = "?"
    var type: Int = 0
    var alive: Bool = false
    var timeReliable: Bool = false
    var mode: String = "?"
    var rawString: String = "?"
    
    mutating func from(_ jsonData: AnyObject) throws {
        
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        
        try self.gatewayId = JSONUtils.string("gatewayId", json: json)
        try self.type = JSONUtils.int("type", json: json)
        do {
            try self.alive = JSONUtils.bool("alive", json: json)
        } catch JSONCompatibleError.missingField {
            print("ERROR 'alive' field is missing on Gateway \(self.gatewayId)")
        }
        try self.timeReliable = JSONUtils.bool("timeReliable", json: json)
        try self.mode = JSONUtils.string("mode", json: json)
    }
}

public struct Device : JSONCompatible, Displayable {
    
    var creationTime:Date = Date()
    var lastUpdateTime:Date = Date()
    var controllableName: String = "?"
    var definition: DeviceDefinition = DeviceDefinition()
    var deviceURL: String = "?"
    var label: String = "?"
    var shortcut: Bool = false
    var available: Bool = false
    var enabled: Bool = false
    var placeOID: String = "?"
    var widget: String = "?"
    var type:Int = 0
    var oid: String = "?" // the device UUID
    var uiClass: String = "?"
    var states:[DeviceStateOrAttribute] = []
    var attributes:[DeviceStateOrAttribute] = []

    var rawString: String = "?"

    var title: String {
        return label
    }
    var detail: String {
        return definition.type
    }
    
    mutating func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        try self.creationTime = JSONUtils.timestamp("creationTime", json: json)
        try self.lastUpdateTime = JSONUtils.timestamp("lastUpdateTime", json: json)
        try self.label = JSONUtils.string("label", json: json)
        try self.deviceURL = JSONUtils.string("deviceURL", json: json)
        try self.controllableName = JSONUtils.string("controllableName", json: json)
        try self.shortcut = JSONUtils.bool("shortcut", json: json)
        try self.available = JSONUtils.bool("available", json: json)
        try self.enabled = JSONUtils.bool("enabled", json: json)
        try self.placeOID = JSONUtils.string("placeOID", json: json)
        try self.widget = JSONUtils.string("widget", json: json)
        try self.type = JSONUtils.int("type", json: json)
        try self.oid = JSONUtils.string("oid", json: json)
        try self.uiClass = JSONUtils.string("uiClass", json: json)

        if let deviceDefinition = json["definition"] {
            try self.definition.from(deviceDefinition as AnyObject)
        }
        
        if let statesData = json["states"] {
            for stateData in statesData as! [AnyObject] {
                var state = DeviceStateOrAttribute()
                do {
                    try state.from(stateData)
                    states.append(state)
                }
            }
        }
        
        if let attributesData = json["attributes"] {
            for attributeData in attributesData as! [AnyObject] {
                var attribute = DeviceStateOrAttribute()
                do {
                    try attribute.from(attributeData)
                    attributes.append(attribute)
                }
            }
        }
    }
}

public struct DeviceStateOrAttribute : JSONCompatible, Displayable {
    var name: String = "?"
    var type: Int = 0
    var value: AnyObject?
    var rawString: String = "?"
        
    var title: String {
        return name
    }
    var detail: String {
        switch type {
        case 1: // Int
            let result = value as! Int
            return "\(result)"
        case 3: // String
            return value as! String
        case 6: // Boolean
            let result = value as! Bool
            return result ? "True" : "False"
        case 10: // JSON
            return "[...json...]" // (value?.description)!
        default:
            return rawString
        }
    }
    
    mutating internal func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        
        try self.name = JSONUtils.string("name", json: json)
        try self.type = JSONUtils.int("type", json: json)
        self.value = json["value"]
    }
}

public struct DeviceDefinition : JSONCompatible {
    var commands:[DeviceCommand] = []

    var widgetName: String = "?"
    var uiClass: String = "?"
    var type: String = "?"
    var rawString: String = "?"
    
    mutating internal func from(_ jsonData: AnyObject) throws {
        
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        
        for commandData in json["commands"] as! [AnyObject] {
            var c:DeviceCommand = DeviceCommand()
            do {
                try c.from(commandData)
                commands.append(c)
            }
        }
        
        try self.widgetName = JSONUtils.string("widgetName", json: json)
        try self.uiClass = JSONUtils.string("uiClass", json: json)
        try self.type = JSONUtils.string("type", json: json)
    }
}

public struct DeviceCommand : JSONCompatible, Displayable {

    var name: String = "?"
    var nparams = 1
    var rawString: String = "?"
    
    var title: String {
        return name
    }
    var detail: String {
        return "\(nparams) parameters"
    }
    
    mutating internal func from(_ jsonData: AnyObject) throws {

        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        
        try self.name = JSONUtils.string("commandName", json: json)
        try self.nparams = JSONUtils.int("nparams", json: json)
    }
}

public struct Setup : JSONCompatible {
    
    var id: String = "?"
    
    var gateways:[Gateway] = []
    var devices:[Device] = []
    var location:Location = Location() {
        didSet {
            print("Location updated") // FIXME Save this
        }
    }

    var rawString: String = "?"
    
    /** Categories are computed after Setup is loaded, they are not part of the JSON.
     */
    var categories: [DeviceCategory] = []
    
    mutating func from(_ jsonData: AnyObject) throws {

        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        
        try self.id = JSONUtils.string("id", json: json)
        
        do {
            try self.location.from(json["location"] as AnyObject)
        } catch JSONCompatibleError.missingField {
            print("ERROR 'location' is missing on Setup \(self.id)")
        }
        
        for gatewayData in json["gateways"] as! [AnyObject] {
            var g:Gateway = Gateway()
            do {
                try g.from(gatewayData)
                gateways.append(g)
            }
        }
        for deviceData in json["devices"] as! [AnyObject] {
            var d:Device = Device()
            do {
                try d.from(deviceData)
                devices.append(d)
            }
        }
        devices.sort { (d1, d2) -> Bool in
            return d1.deviceURL.localizedStandardCompare(d2.deviceURL) == .orderedAscending
        }
        
        self.categories = lookupCategories()
    }
}

public struct Location : JSONCompatible {
    
    var creationTime:Date = Date()
    var lastUpdateTime:Date = Date()
    var city:String = "?"
    var country:String = "?"
    var postalCode:String = "?"
    var addressLine1:String = "?"
    var timezone:String = "?" // "Europe/Madrid"
    var longitude:Float = 0 // 2.0969
    var latitude:Float = 0 // 41.3553
    var twilightMode:Int = 2
    var twilightAngle:String = "?" // TODO options "CIVIL",
    var twilightCity:String = "?" // "Barcelona"
    var summerSolsticeDuskMinutes:Int = 0 // 1290
    var winterSolsticeDuskMinutes:Int = 0 // 990
    var twilightOffsetEnabled:Bool = false
    var dawnOffset:Int = 0
    var duskOffset:Int = 0
    
    var rawString: String = "?"

    mutating internal func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        
        try self.creationTime = JSONUtils.timestamp("creationTime", json: json)
        try self.lastUpdateTime = JSONUtils.timestamp("lastUpdateTime", json: json)
        try self.city = JSONUtils.string("city", json: json)
        try self.country = JSONUtils.string("country", json: json)
        try self.postalCode = JSONUtils.string("postalCode", json: json)
        try self.addressLine1 = JSONUtils.string("addressLine1", json: json)
        try self.timezone = JSONUtils.string("timezone", json: json)
        // TODO use jsonData.value(forKey: "longitude")
        try self.longitude = JSONUtils.float("longitude", json: json)
        try self.latitude = JSONUtils.float("latitude", json: json)
        try self.twilightMode = JSONUtils.int("twilightMode", json: json)
        try self.twilightAngle = JSONUtils.string("twilightAngle", json: json)
        try self.twilightCity = JSONUtils.string("twilightCity", json: json)
        try self.summerSolsticeDuskMinutes = JSONUtils.int("summerSolsticeDuskMinutes", json: json)
        try self.winterSolsticeDuskMinutes = JSONUtils.int("winterSolsticeDuskMinutes", json: json)
        try self.twilightOffsetEnabled = JSONUtils.bool("twilightOffsetEnabled", json: json)
        try self.dawnOffset = JSONUtils.int("dawnOffset", json: json)
        try self.duskOffset = JSONUtils.int("duskOffset", json: json)
    }

    
    mutating func buildRawString() {        
        let jsonString = "{\"creationTime\": \(TimeUtils.timestampMilliSecs(self.creationTime)), \"lastUpdateTime\": \(TimeUtils.timestampMilliSecs(self.lastUpdateTime)), \"city\": \"\(self.city)\",\"country\": \"\(self.country)\", \"postalCode\": \"\(self.postalCode)\", \"addressLine1\": \"\(self.addressLine1)\", \"timezone\": \"\(self.timezone)\", \"longitude\": \(self.longitude), \"latitude\": \(self.latitude), \"twilightMode\": \(self.twilightMode), \"twilightAngle\": \"\(self.twilightAngle)\", \"twilightCity\": \"\(self.twilightCity)\", \"summerSolsticeDuskMinutes\": \(self.summerSolsticeDuskMinutes), \"winterSolsticeDuskMinutes\": \(self.winterSolsticeDuskMinutes), \"twilightOffsetEnabled\": \(self.twilightOffsetEnabled), \"dawnOffset\": \(self.dawnOffset), \"duskOffset\": \(self.duskOffset) }"

        rawString = jsonString
    }
    
    func toJson() -> Data {
        let json:Data = rawString.data(using: .utf8)!
        return json
    }
 }


public struct ActionCommand : JSONCompatible {
    var type: Int = 1
    var name: String = "?"
    var parameters: [AnyObject] = []
    var rawString: String = "?"
    
    init() {}
    init(command: DeviceCommand) {
        name = command.name
        parameters = Array(repeating: "?" as AnyObject, count: command.nparams)
        buildRawString()
    }
    
    init(command: DeviceCommand, p1: String, p2: String = "") {
        name = command.name
        if p1 != "" {
            parameters.append(p1 as AnyObject)
            if p2 != "" {
                parameters.append(p2 as AnyObject)
            }
        }
        buildRawString()
    }
    
    mutating internal func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        do {
            try self.type = JSONUtils.int("type", json: json)
        } catch JSONCompatibleError.missingField(let field) {
            print("WARNING missing field '\(field)' on ActionCommand")
        }
        try self.name = JSONUtils.string("name", json: json)
        self.parameters = json["parameters"] as! [AnyObject]
    }
    
    mutating func buildRawString() {
        // Note: works when removing the type...
//        var jsonString = "{\"type\": \(self.type), \"name\": \"\(self.name)\", \"parameters\" : ["
        var jsonString = "{\"name\": \"\(self.name)\", \"parameters\" : ["
        if parameters.count > 0 {
            for parameter in self.parameters {
                jsonString += "\"\(parameter)\","
            }
            // remove extra ","
            let index = jsonString.index(before: jsonString.endIndex)
            jsonString.remove(at: index)
        }
        jsonString += "] }"
        rawString = jsonString
    }
    
    func toJson() -> Data {
        let json:Data = rawString.data(using: .utf8)!
        return json
    }

}

public struct Action : JSONCompatible {
    
    var deviceURL: String = "?"
    var commands: [ActionCommand] = []
    var rawString: String = "?"
    
    init() {}
    init(deviceUrl url:String, command: ActionCommand) {
        deviceURL = url
        commands.append(command)
        buildRawString()
    }
    init(deviceUrl url:String, commandList: [ActionCommand]) {
        deviceURL = url
        commands = Array(commandList)
        buildRawString()
    }
    
    mutating internal func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        
        try self.deviceURL = JSONUtils.string("deviceURL", json: json)
        for commandData in json["commands"] as! [AnyObject] {
            var d:ActionCommand = ActionCommand()
            do {
                try d.from(commandData)
                commands.append(d)
            }
        }
    }
    
    mutating func buildRawString() {
        var jsonString = "{\"deviceURL\": \"\(self.deviceURL)\", \"commands\" : ["
        for command in self.commands {
            jsonString += "\(command.rawString),"
        }
        // remove extra ","
        let index = jsonString.index(before: jsonString.endIndex)
        jsonString.remove(at: index)
        
        jsonString += "] }"
        rawString = jsonString
    }
    
    func toJson() -> Data {
        let json:Data = rawString.data(using: .utf8)!
        return json
    }
}

public struct ActionGroup : JSONCompatible, Displayable {
    var label: String = "?"
    var metadata: String = "?"
    var actions: [Action] = []
    var rawString: String = "?"

    var title: String {
        return label
    }
    var detail: String {
        return rawString
    }
    
    //        let group = ActionGroup(label:"\(deviceCommand!.name) on \(device!.controllableName)", action:action)
    init() {}
    init(_ label:String, action: Action) {
        self.label = label
        actions.append(action)
        metadata = ""
        buildRawString()
    }
    
    mutating internal func from(_ jsonData: AnyObject) throws {
        
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        
        try self.label = JSONUtils.string("label", json: json)
        try self.metadata = JSONUtils.string("metadata", json: json)
        for actionData in json["actions"] as! [AnyObject] {
            var a:Action = Action()
            do {
                try a.from(actionData)
                actions.append(a)
            }
        }
    }

    mutating func buildRawString() {
        var jsonString = "{\"label\": \"\(self.label)\", \"metadata\": \"\(self.metadata)\", \"actions\" : ["
        for action in self.actions {
            jsonString += "\(action.rawString),"
        }
        // remove extra ","
        let index = jsonString.index(before: jsonString.endIndex)
        jsonString.remove(at: index)
        
        jsonString += "] }"
        rawString = jsonString
    }
    
    func toJson() -> Data {
        let json:Data = rawString.data(using: .utf8)!
        return json
    }
}

// MARK: - Events

enum EventName: String, CaseIterable, Codable, Hashable {
    case ExecutionRegistered = "ExecutionRegisteredEvent"
    case ExecutionStateChanged = "ExecutionStateChangedEvent"
    case GatewaySynchronizationStarted = "GatewaySynchronizationStartedEvent"
    case GatewaySynchronizationFailed = "GatewaySynchronizationFailedEvent"
    case GatewaySynchronizationEnded = "GatewaySynchronizationEndedEvent"
    case CommandExecutionStateChanged = "CommandExecutionStateChangedEvent"
    case DeviceUnavailable = "DeviceUnavailableEvent"
    case DeviceStateChanged = "DeviceStateChangedEvent"
    case Unknown
    
    static func lookup(name: String) -> EventName {
        for eventName in EventName.allCases {
            if name == eventName.rawValue {
                return eventName
            }
        }
        return .Unknown
    }
}

public class Event : JSONCompatible {
    var rawString: String = "?"

    var name: EventName = .Unknown
    var timestamp = Date()

    internal func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        try self.timestamp = JSONUtils.timestamp("timestamp", json: json)
        let eventName = try JSONUtils.string("name", json: json)
        self.name = EventName.lookup(name: eventName)
    }
}

public class ExecutionRegisteredEvent: Event {
    var setupOID: String = "?"
    var execId: String = "?"
    var label: String = "?"
    var metadata: String = "?"
    var type: Int = 0
    var subType: Int = 0
    //actions : []

    // FIXME Add function from(Event)

    internal override func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        try self.timestamp = JSONUtils.timestamp("timestamp", json: json)
        let eventName = try JSONUtils.string("name", json: json)
        self.name = EventName.lookup(name: eventName)
        try self.setupOID = JSONUtils.string("setupOID", json: json)
        try self.execId = JSONUtils.string("execId", json: json)
        try self.label = JSONUtils.string("label", json: json)
        try self.metadata = JSONUtils.string("metadata", json: json)
        try self.type = JSONUtils.int("type", json: json)
        try self.subType = JSONUtils.int("subType", json: json)
    }
}

public class ExecutionStateChangedEvent: Event {
    var setupOID: String = "?"
    var execId: String = "?"
    var ownerKey: String = "?"
    var newState: String = "?" // ExecutionStateChangedEvent.State = .unitialized
    var oldState: String = "?" // ExecutionStateChangedEvent.State = .unitialized
    var type: Int = 0
    var subType: Int = 0
    var timeToNextState: Int = 0
    
    enum State: CaseIterable {
        case unitialized // default
        case initialized
        case not_transmitted
        case transmitted
        case in_progress
        case completed
        case failed
    }

    // FIXME Add function from(Event)

    internal override func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        try self.timestamp = JSONUtils.timestamp("timestamp", json: json)
        let eventName = try JSONUtils.string("name", json: json)
        self.name = EventName.lookup(name: eventName)
        try self.setupOID = JSONUtils.string("setupOID", json: json)
        try self.execId = JSONUtils.string("execId", json: json)
        try self.ownerKey = JSONUtils.string("ownerKey", json: json)
        try self.newState = JSONUtils.string("newState", json: json)
        try self.oldState = JSONUtils.string("oldState", json: json)
        try self.type = JSONUtils.int("type", json: json)
        try self.subType = JSONUtils.int("subType", json: json)
        try self.timeToNextState = JSONUtils.int("timeToNextState", json: json)
    }
}
/**
  * Cover both GatewaySynchronizationStarted, GatewaySynchronizationFailed and GatewaySynchronizationEnded
 */
public class GatewaySynchronizationEvent: Event {
    var gatewayId: String = "?"
    var failureType: String  = "?" // (Enum?)

    // FIXME Add function from(Event)
    
    internal override func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        try self.timestamp = JSONUtils.timestamp("timestamp", json: json)
        let eventName = try JSONUtils.string("name", json: json)
        self.name = EventName.lookup(name: eventName)
        try self.gatewayId = JSONUtils.string("gatewayId", json: json)
        if self.name == .GatewaySynchronizationFailed {
            try self.failureType = JSONUtils.string("failureType", json: json)
        }
    }
}


public struct APIError : JSONCompatible {

    var error: String = "?"
    var errorCode: String = "?"
    var rawString: String = "?"
    
    mutating internal func from(_ jsonData: AnyObject) throws {
        self.rawString = jsonData.description
        guard let json = jsonData as? [String: AnyObject] else {
            throw JSONCompatibleError.invalidJSONData
        }
        try self.error = JSONUtils.string("error", json: json)
        try self.errorCode = JSONUtils.string("errorCode", json: json)
        
    }
    
    init(_ jsonData: AnyObject) {
        do {
            try from(jsonData)
        } catch {
            print("ERROR Failed to parse json")
        }
    }
}
