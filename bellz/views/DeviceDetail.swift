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
    
    @State private var showAdvanced = false
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
        self.message = ""
        session.execute(command: command, on: device, p1: param1, p2: param2)
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DeviceRow(device: device)
            Text("\(device.category.name) commands").bold()
            List {
                ForEach(simpleCommands, id: \.name) { command in
                    Button(action: {
                            self.runActionGroup(command)
                        }) {
                            Text(command.name)
                        }
                }
                ForEach(otherCommands, id: \.name) { command in
                    NavigationLink(destination: CommandDetail(device: self.device, command: command)) {
                        Text(command.name)
                    }
                }
            }
            .frame(height: 200)
            Divider()
            Toggle(isOn: $showStates) {
                Text("Values").bold()
            }
            List {
                ForEach(device.states, id: \.name) { state in
                    DeviceValue(label: state.title, value: state.detail)
                }
                ForEach(device.attributes, id: \.name) { attribute in
                    DeviceValue(label: attribute.title, value: attribute.detail)
                }
            }
            .opacity(showStates ? 1 : 0)
            .frame(height: (showStates ? 200 : 0))
            //.animation(.default)
            Divider()
            Toggle(isOn: $showAdvanced) {
                Text("Technical information")
            }
            List {
                Text(verbatim: message).fontWeight(.light).italic()
                DeviceValue(label: "ui class", value: device.uiClass)
                DeviceValue(label: "url", value: device.deviceURL)
                DeviceValue(label: "ctrl", value: device.controllableName)
                DeviceValue(label: "detail", value: device.detail)
                DeviceValue(label: "last update", value: device.lastUpdateTime.description)
            }
            .opacity(showAdvanced ? 1 : 0) // workaround as .hidden() has no boolean
            .frame(height: (showAdvanced ? 200 : 0))
            //.animation(.default)
            Spacer()
        }.padding()
        .navigationBarTitle(Text(device.title))
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
        DeviceDetail(device: Session.demoSession.setup.devices[3])
            .environmentObject(Session.demoSession)
    }
}
