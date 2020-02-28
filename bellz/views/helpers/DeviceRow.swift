//
//  DeviceRow.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 16/10/2019.
//  Copyright © 2019 noion. All rights reserved.
//

import SwiftUI

struct DeviceRow: View {
    var device: Device
    
    var body: some View {
        HStack {
            CategoryLogo(category: device.category)
                .frame(width: 50, height: 50)
            Text(verbatim: device.label)
            Spacer()
        }
    }
}

struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeviceRow(device: Session.demoSession.setup.devices[2])
            DeviceRow(device: Session.demoSession.setup.devices[3])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
