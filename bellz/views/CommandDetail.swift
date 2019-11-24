//
//  CommandDetail.swift
//  bellz
//
//  Created by Laurent ZILBER on 02/11/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import SwiftUI

struct CommandDetail: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var session: Session
    var device: Device
    var command: DeviceCommand
    
    var header: String {
        return "\(command.name) has "
            + (command.nparams < 1 ? "no parameters." :
                command.nparams < 2 ? "one parameter." :
                    "\(command.nparams) parameters" )
    }
    
    @State private var param1: String = ""
    @State private var param2: String = ""
    @State private var isContactingServer = false
    @State private var showVictory = false

    let publisher = NotificationCenter.default.publisher(for: Session.executeActionGroup)
        .map { notification in
            return notification.userInfo?["error"] as! String
        }
        //.print("DEBUG executeActionGroup notification")
        .receive(on: RunLoop.main)

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {
            Form {
                Section(header: Text(header)) {
                    if command.nparams > 0 {
                        TextField("First parameter", text: $param1)
                    }
                    if command.nparams > 1 {
                        TextField("Second parameter", text: $param2)
                    }
                    Button(action: {
                        self.runActionGroup()
                        self.isContactingServer = true
                    }) {
                        Text("Run command")
                    }
                }
            }
            .disabled(isContactingServer)
            .onReceive(publisher) { (error_msg) in
                self.isContactingServer = false
                if error_msg == "" {
                    // ActionGroup successfully sent, pop this view
                    if self.session.didShowVictory {
                        if self.session.soundEnabled {
                            Jukebox.instance.playLowNote()
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        self.session.didShowVictory = true
                        self.showVictory = true
                    }
                }
            }
        }
        .navigationBarTitle(Text(device.title))
        .sheet(isPresented: $showVictory, onDismiss: {
            // print("DEBUG onDismiss called for presented sheet")
        }) {
            Victory(message: "You succesfully executed your first command with a parameter!")
        }
    }

    private func runActionGroup() {
        session.execute(command: command, on: device, p1: param1, p2: param2)
    }
    
}

struct CommandDetail_Previews: PreviewProvider {
    static var previews: some View {
        CommandDetail(device: Session.demoSession.setup.devices[3], command: Session.demoSession.setup.devices[3].definition.commands[2])
            .environmentObject(Session.demoSession)
    }
}
