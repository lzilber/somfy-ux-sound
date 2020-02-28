//
//  CommandList.swift
//  bellz
//
//  Created by Laurent ZILBER on 20/01/2020.
//  Copyright © 2020 zebre.org. All rights reserved.
//

import SwiftUI

struct CommandList: View {
    var device: Device
    @EnvironmentObject var session: Session
    @State private var param1: String = ""
    @State private var param2: String = ""

    var simpleCommands: [DeviceCommand] {
        return device.definition.commands.filter {
            $0.nparams == 0 // TODO : and not technical
        }.sorted { (c1, c2) -> Bool in
            c1.name < c2.name
        }
    }
    
    var otherCommands : [DeviceCommand] {
        return device.definition.commands.filter {
            $0.nparams > 0 // TODO : and not technical
        }.sorted { (c1, c2) -> Bool in
            c1.name < c2.name
        }
    }
    
    private func runActionGroup(_ command: DeviceCommand) {
        session.execute(command: command, on: device, p1: param1, p2: param2)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            List {
                ForEach(simpleCommands, id: \.name) { command in
                    Button(action: {
                        self.runActionGroup(command)
                    }) {
                        Text(verbatim: command.name)
                    }
                }
                ForEach(otherCommands, id: \.name) { command in
                    NavigationLink(destination: CommandDetail(device: self.device, command: command)) {
                        Text(verbatim:command.name)
                    }
                }
            }
        }
        .navigationBarTitle(Text(device.title))
    }
}

struct CommandList_Previews: PreviewProvider {
    static var previews: some View {
        CommandList(device: Session.demoSession.setup.devices[3])
            .environmentObject(Session.demoSession)
    }
}
