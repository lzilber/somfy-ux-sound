//
//  DeviceDetail.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 16/10/2019.
//  Copyright © 2019 noion. All rights reserved.
//

import SwiftUI

struct DeviceDetail: View {
    var device: Device
    
    @State private var showAdvanced = true
    @State private var showStates = false
    @State private var param1: String = ""
    @State private var param2: String = ""
    @State private var message: String = ""

    @EnvironmentObject var session: Session

    let actionPublisher = NotificationCenter.default.publisher(for: Session.executeActionGroup)
        .map { notification in
            return notification.userInfo?["error"] as! String
        }
        .receive(on: RunLoop.main)

    let statePublisher = NotificationCenter.default.publisher(for: EventManager.executionStateChanged)
        .map { notification in
            return notification.userInfo?["state"] as! String
        }
        .receive(on: RunLoop.main)
        
    private func runActionGroup(_ command: DeviceCommand) {
        self.message = ""
        session.execute(command: command, on: device, p1: param1, p2: param2)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DeviceRow(device: device)
            List {
                ForEach(device.categoryCommands(), id: \.name) { command in
                    Button(action: {
                        self.runActionGroup(command)
                    }) {
                        CommandRow(command: command)
                    }
                }
                NavigationLink(destination: CommandList(device: self.device)) {
                    Text("All commands")
                }
                NavigationLink(destination: DeviceValueList(device: self.device)) {
                    Text("All values")
                }
                NavigationLink(destination: DeviceTechnicalInfo(device: self.device)) {
                    Text("Technical information")
                }
            }
        }
        .padding()
        .navigationBarTitle(Text(device.category.name()))
        .onReceive(actionPublisher) { (error_msg) in
            if error_msg == "" {
                if self.session.soundEnabled {
                    Jukebox.instance.playLowNote()
                }
            } else {
                self.message = "An error occured: \(error_msg)."
            }
        }
        .onReceive(statePublisher) { (state) in
            if state == "COMPLETED" || state == "FAILED" {
                print("DEBUG (maybe) playing sound for new state \(state)")
                self.message = state
                if self.session.soundEnabled {
                    Jukebox.instance.playHighNote()
                }
            } else {
                print("DEBUG ignoring notification for new state \(state)")
                self.message = state
            }
        }
        .onAppear() {
            self.session.eventManager!.start()
        }
        .onDisappear() {
            self.session.eventManager!.stop()
        }
    }
    
}

struct DeviceValue: View {
    var label: String = ""
    var value: String = ""
    var body: some View {
        HStack {
            Text("\(label) :")
            Text(value).italic()
        }
    }
}


struct DeviceDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceDetail(device: Session.demoSession.setup.devices[3])
                .environmentObject(Session.demoSession)
        }
    }
}
