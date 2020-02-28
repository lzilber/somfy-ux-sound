//
//  CommandRow.swift
//  bellz
//
//  Created by Laurent ZILBER on 21/01/2020.
//  Copyright © 2020 zebre.org. All rights reserved.
//

import SwiftUI

struct CommandRow: View {
    var command: DeviceCommand
    
    var parametersText: String {
        var text: String = "\(command.nparams) parameter"
        if command.nparams > 1 {
            text.append("s")
        }
        return text
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "arrowtriangle.right.circle")
                Text(command.name)
                Spacer()
            }
            HStack {
                if command.nparams > 0 {
                    Text(verbatim: parametersText).font(.caption)
                    Spacer()
                }
            }
        }
    }
}

struct CommandRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CommandRow(command: Session.demoSession.setup.devices[3].definition.commands[2])
            CommandRow(command: Session.demoSession.setup.devices[3].definition.commands[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))

    }
}
