//
//  GatewayAlive.swift
//  bellz
//
//  Created by Laurent ZILBER on 27/01/2020.
//  Copyright © 2020 zebre.org. All rights reserved.
//

import SwiftUI

struct GatewayAlive: View {
    var gateway: Gateway
    private var color: Color {
        if gateway.alive {
            return .green
        } else {
            return .red
        }
    }
    private var accessibilityText: String {
        if gateway.alive {
            return "Connected"
        } else {
            return "Disconnected"
        }
    }
    var body: some View {
        Image(systemName: "circle.fill")
            .imageScale(.large)
            .foregroundColor(self.color)
            .accessibility(label: Text(self.accessibilityText))
            .padding()
    }
}

struct GatewayAlive_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GatewayAlive(gateway: Session.demoSession.setup.gateways[0])
            GatewayAlive(gateway: Gateway(gatewayId: "1234-5678-9101", type: 1, alive: true, timeReliable: true, mode: ""))
        }
        .previewLayout(.fixed(width: 44, height: 44))
    }
}
