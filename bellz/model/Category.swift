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

class DeviceCategoryCatalog {
    
    var allCategories:[DeviceCategory] = []
        
    static let instance: DeviceCategoryCatalog = {
        let catalog = DeviceCategoryCatalog()
        catalog.allCategories = catalog.loadCategoriesFromFile("device-categories.json")
        return catalog
    } ()
    
    /** Parse a list of DeviceCategory from JSON data.
     Uses  JSONDecoder. The array is empty if the decoder throws an error.
     */
    func loadCategories(json: Data) -> [DeviceCategory] {
        let decoder = JSONDecoder()
        do {
            let categories = try decoder.decode([DeviceCategory].self, from: json)
            return categories
        } catch {
            print("ERROR Failed to load device categories:" + error.localizedDescription )
            print(error)
            return []
        }
    }
    
    func loadCategoriesFromFile(_ filename: String) -> [DeviceCategory] {
        let fileparts = filename.components(separatedBy: ".")
        if let fileURL = Bundle.main.url(forResource: fileparts[0], withExtension: fileparts[1]) {
            let jsonData = try? Data(contentsOf: fileURL)
            if let data = jsonData {
                return loadCategories(json: data)
            }
            print("ERROR Failed to load device categories from file:" + filename )
        }
        print("ERROR File (Bundle URL) not found:" + filename )
        return []
    }
    
    func lookup(name: String) -> DeviceCategory {
        if let typeOfDevice = TypeOfDevice(rawValue: name) {
            return lookup(type: typeOfDevice)
        }
        print("WARNING: no matching type for name:" + name)
        return DeviceCategoryUnknown
    }
    
    func lookup(type: TypeOfDevice) -> DeviceCategory {
        for category in allCategories {
            if category.type == type {
                return category
            }
        }
        print("WARNING: type not found in allCategories:" + type.rawValue)
        return DeviceCategoryUnknown
    }
}

struct DeviceCategory: Hashable, Identifiable, Codable {
    
    let id: String
    let type: TypeOfDevice
    var shortcuts: [String]?
    var valuesOfInterest: [String]?
        
    init(type: TypeOfDevice) {
        self.id = type.rawValue.lowercased()
        self.type = type
    }

    init(type: TypeOfDevice, shortcuts: [String], valuesOfInterest: [String]) {
        self.init(type: type)
        self.shortcuts = shortcuts
        self.valuesOfInterest = valuesOfInterest
    }
    
    func name() -> String {
        return type.rawValue
    }
}

let DeviceCategoryUnknown = DeviceCategory(type: .unknown)

extension Device {

    func lookupCategory() -> DeviceCategory {
        print("DEBUG lookupCategory called on \(self.uiClass)")
        
        // FIXME add uiClass mapping to JSON catalog?

        var category = DeviceCategoryUnknown
        let catalog = DeviceCategoryCatalog.instance
        // First look if uiClass matches a type
        category = catalog.lookup(name: self.uiClass)
        if category != DeviceCategoryUnknown {
            return category
        }
        
        // If unknown, look for specific cases
        switch self.uiClass {
        case "ConfigurationComponent", "Dock":
            category = catalog.lookup(type: TypeOfDevice.technical)
        case "ElectricitySensor":
            category = catalog.lookup(type: TypeOfDevice.electrical)
        case "ExteriorVenetianBlind", "Screen", "VenetianBlind":
            category = catalog.lookup(type: TypeOfDevice.blinds)
        case "IRBlasterController", "RemoteController":
            category = catalog.lookup(type: TypeOfDevice.remote_control)
        case "NetworkComponent":
            category = catalog.lookup(type: TypeOfDevice.network)
        case "OnOff":
            category = catalog.lookup(type: TypeOfDevice.switch_onoff)
        case "Plug":
            category = catalog.lookup(type: TypeOfDevice.outlet)
        case "Pod", "ProtocolGateway":
            category = catalog.lookup(type: TypeOfDevice.gateway)
        case "RollerShutter":
            category = catalog.lookup(type: TypeOfDevice.shutter)
        case "OccupancySensor","ContactSensor":
            category = catalog.lookup(type: TypeOfDevice.sensor)
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
