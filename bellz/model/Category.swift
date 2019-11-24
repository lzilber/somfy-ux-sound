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
    var name : String // FIXME Localize
    
    init(id: String, type: TypeOfDevice) {
        self.id = id
        self.type = type
        self.name = id
    }
    
    init(type: TypeOfDevice) {
        self.init(id: type.rawValue, type: type)
    }
}

let DeviceCategoryAwning  = DeviceCategory(type: .awning)
let DeviceCategoryBlinds  = DeviceCategory(type: .blinds)
let DeviceCategoryCurtain = DeviceCategory(type: .curtain)
let DeviceCategoryGateway = DeviceCategory(type: .gateway)
let DeviceCategoryElectrical = DeviceCategory(type: .electrical)
let DeviceCategoryLight   = DeviceCategory(type: .light)
let DeviceCategoryNetwork = DeviceCategory(type: .network)
let DeviceCategoryOutlet  = DeviceCategory(type: .outlet)
let DeviceCategoryOnOff   = DeviceCategory(type: .switch_onoff)
let DeviceCategoryRemote  = DeviceCategory(type: .remote_control)
let DeviceCategoryShutter = DeviceCategory(type: .shutter)
let DeviceCategoryTechnical = DeviceCategory(type: .technical)

//
let DeviceCategoryUnknown = DeviceCategory(type: .unknown)

extension Device {
    var category: DeviceCategory {
        return lookupCategory()
    }
    
    fileprivate func lookupCategory() -> DeviceCategory {
        // FIXME define this in external JSON file mapping uiClass <-> category
        // First look on uiClass
        if self.uiClass == "ConfigurationComponent" {
            return DeviceCategoryTechnical
        }
        if self.uiClass == "Curtain" {
            return DeviceCategoryCurtain
        }
        if self.uiClass == "ElectricitySensor" {
            return DeviceCategoryElectrical
        }
        if self.uiClass == "ExteriorVenetianBlind" || self.uiClass == "Screen" || self.uiClass == "VenetianBlind"{
            return DeviceCategoryBlinds
        }
        if self.uiClass == "IRBlasterController" || self.uiClass == "RemoteController" {
            return DeviceCategoryRemote
        }
        if self.uiClass == "Light" {
            return DeviceCategoryLight
        }
        if self.uiClass == "NetworkComponent" {
            return DeviceCategoryNetwork
        }
        if self.uiClass == "OnOff" {
            return DeviceCategoryOnOff
        }
        if self.uiClass == "Plug" {
            return DeviceCategoryOutlet
        }
        if self.uiClass == "Pod" || self.uiClass == "ProtocolGateway" {
            return DeviceCategoryGateway
        }
        if self.uiClass == "RollerShutter" {
            return DeviceCategoryShutter
        }
        print("DEBUG unknown \(self.uiClass)")
        
        return DeviceCategoryUnknown
    }
}

extension Setup {
    
    var categories: [DeviceCategory] {
        print("FIXME lookupCategories CALLED")
        return lookupCategories()
    }
        
    fileprivate func lookupCategories() -> [DeviceCategory] {
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
