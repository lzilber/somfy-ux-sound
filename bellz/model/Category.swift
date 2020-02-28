//
//  Category.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 16/10/2019.
//  Copyright © 2019 noion. All rights reserved.
//

import Foundation
import UIKit

enum TypeOfDevice: String, CaseIterable, Codable, Hashable {
    case alarm = "Alarm"
    case awning = "Awning"
    case blinds = "Blinds"
    case camera = "Camera"
    case curtain = "Curtain"
    case door = "Door"
    case electrical = "Electrical"
    case garage_door = "Garage Door"
    case gate = "Gate"
    case gateway = "Gateway"
    case heater = "Heater"
    case light = "Light"
    case lock = "Lock"
    case network = "Network"
    case outlet = "Outlet"
    case pergola = "Pergola"
    case remote_control = "Remote Control"
    case sensor = "Sensor" // FIXME sensor enum
    case shutter = "Shutter"
    case switch_onoff = "Switch"
    case thermostat = "Thermostat"
    case technical = "Technical"
    case window = "Window"
    case unknown = "Unknown"
}

struct DeviceCategory: Hashable, Identifiable { //Codable
    let id: String
    let type: TypeOfDevice
    var name : String // TODO Localize
    var shortcuts: [String]?
    var valuesOfInterest: [String]?

    init(id: String, type: TypeOfDevice) {
        self.id = id
        self.type = type
        self.name = id
    }
    
    init(type: TypeOfDevice) {
        self.init(id: type.rawValue, type: type)
    }

    init(type: TypeOfDevice, shortcuts: [String], valuesOfInterest: [String]) {
        self.init(type: type)
        self.shortcuts = shortcuts
        self.valuesOfInterest = valuesOfInterest
    }
}

let DeviceCategoryAlarm  = DeviceCategory(type: .alarm)
let DeviceCategoryAwning  = DeviceCategory(type: .awning, shortcuts: ["open", "close"], valuesOfInterest: ["core:ClosureState"])
let DeviceCategoryBlinds  = DeviceCategory(type: .blinds, shortcuts: ["open", "close"], valuesOfInterest: ["core:ClosureState"])
let DeviceCategoryCurtain = DeviceCategory(type: .curtain, shortcuts: ["open", "close"], valuesOfInterest: ["core:ClosureState"])
let DeviceCategoryGateway = DeviceCategory(type: .gateway)
let DeviceCategoryElectrical = DeviceCategory(type: .electrical)
let DeviceCategoryLight   = DeviceCategory(type: .light, shortcuts: ["on", "off"], valuesOfInterest: ["core:OnOffState"])
let DeviceCategoryNetwork = DeviceCategory(type: .network)
let DeviceCategoryOutlet  = DeviceCategory(type: .outlet)
let DeviceCategoryOnOff   = DeviceCategory(type: .switch_onoff, shortcuts: ["on", "off"], valuesOfInterest: ["core:OnOffState"])
let DeviceCategoryRemote  = DeviceCategory(type: .remote_control)
let DeviceCategorySensor = DeviceCategory(type: .sensor)
let DeviceCategoryShutter = DeviceCategory(type: .shutter, shortcuts: ["open", "close"], valuesOfInterest: ["core:ClosureState"])
let DeviceCategoryTechnical = DeviceCategory(type: .technical)
//
let DeviceCategoryUnknown = DeviceCategory(type: .unknown)

let categoriesDefinition = """
[
    {
        "id": "Curtain",
        "type": "Curtain",
        "shortcuts": [ "open", "close" ]
    },
    {
        "id": "Light",
        "type": "Light",
        "shortcuts": [ "on", "off" ]
    }
]
"""

extension Device {

    func lookupCategory() -> DeviceCategory {
        print("DEBUG lookupCategory called on \(self.uiClass)")
        // FIXME define this in external JSON file mapping uiClass <-> category
        var category = DeviceCategoryUnknown
        // TODO look in JSon data
        
        
        // First look on uiClass
        switch self.uiClass {
        case "Alarm":
            category = DeviceCategoryAlarm
        case "ConfigurationComponent", "Dock":
            category = DeviceCategoryTechnical
        case "Curtain":
            category = DeviceCategoryCurtain
        case "ElectricitySensor":
            category = DeviceCategoryElectrical
        case "ExteriorVenetianBlind", "Screen", "VenetianBlind":
            category = DeviceCategoryBlinds
        case "IRBlasterController", "RemoteController":
            category = DeviceCategoryRemote
        case "Light":
            category = DeviceCategoryLight
        case "NetworkComponent":
            category = DeviceCategoryNetwork
        case "OnOff":
            category = DeviceCategoryOnOff
        case "Plug":
            category = DeviceCategoryOutlet
        case "Pod", "ProtocolGateway":
            category = DeviceCategoryGateway
        case "RollerShutter":
            category = DeviceCategoryShutter
        case "OccupancySensor","ContactSensor":
            category = DeviceCategorySensor
        default:
            print("INFO unknown \(self.uiClass)")
            category = DeviceCategoryUnknown
        }
        return category
    }
    
    func categoryCommands() -> [DeviceCommand] {
        var result: [DeviceCommand] = []
        for command in self.definition.commands {
            if let deviceShortcuts = self.category.shortcuts {
                if deviceShortcuts.contains(command.name) {
                    result.append(command)
                }
            }
        }
        return result
    }
}

extension Setup {
    
    func lookupCategories() -> [DeviceCategory] {
        print("DEBUG lookupCategories called")
        var result = [DeviceCategory]()
        for device in self.devices {
            let deviceCategory = device.category
            if !result.contains(deviceCategory) {
                result.append(deviceCategory)
            }
        }
        return result
    }
}
