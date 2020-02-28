//
//  DeviceValueList.swift
//  bellz
//
//  Created by Laurent ZILBER on 20/01/2020.
//  Copyright © 2020 zebre.org. All rights reserved.
//

import SwiftUI

struct DeviceValueList: View {
    var device: Device
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            List {
                ForEach(device.states, id: \.name) { state in
                    DeviceValue(label: state.title, value: state.detail)
                }
                ForEach(device.attributes, id: \.name) { attribute in
                    DeviceValue(label: attribute.title, value: attribute.detail)
                }
            }
        }
        .navigationBarTitle(Text(device.title))
    }
}

struct DeviceValueList_Previews: PreviewProvider {
    static var previews: some View {
        DeviceValueList(device: Session.demoSession.setup.devices[3])
    }
}
