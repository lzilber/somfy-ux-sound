//
//  DeviceList.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 16/10/2019.
//  Copyright © 2019 noion. All rights reserved.
//

import SwiftUI

struct DeviceList: View {
    var devices: [Device]
    
    var body: some View {
        List {
            ForEach(devices, id: \.oid) { device in
                NavigationLink(
                    destination: DeviceDetail(device: device)
                ) {
                    DeviceRow(device: device)
                }
            }
        }
        .navigationBarTitle(Text("Devices"))    }
}

struct DeviceList_Previews: PreviewProvider {
    static var previews: some View {
        DeviceList(devices: Session.demoSession.setup.devices)
    }
}
