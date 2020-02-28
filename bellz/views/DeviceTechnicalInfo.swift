//
//  DeviceTechnicalInfo.swift
//  bellz
//
//  Created by Laurent ZILBER on 20/01/2020.
//  Copyright © 2020 zebre.org. All rights reserved.
//

import SwiftUI

struct DeviceTechnicalInfo: View {
    var device: Device

    var body: some View {
        VStack {
            List {
                DeviceValue(label: "ui class", value: device.uiClass)
                DeviceValue(label: "url", value: device.deviceURL)
                DeviceValue(label: "ctrl", value: device.controllableName)
                DeviceValue(label: "detail", value: device.detail)
                DeviceValue(label: "last update", value: device.lastUpdateTime.description)
            }
        }
        .navigationBarTitle(Text(device.title))
    }
}

struct DeviceTechnicalInfo_Previews: PreviewProvider {
    static var previews: some View {
        DeviceTechnicalInfo(device: Session.demoSession.setup.devices[3])
    }
}
