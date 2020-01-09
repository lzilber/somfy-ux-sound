//
//  UserInfoFrame.swift
//  bellz
//
//  Created by Laurent ZILBER on 03/11/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import SwiftUI

struct UserInfoFrame: View {
    
    @EnvironmentObject var session: Session
    @Binding var showingUserInfo: Bool

    @State private var message: String = ""
    @State private var isContactingServer: Bool = false
    @State private var draftLocation: Location = Location()
    @State private var editCancelled = false

    @Environment(\.editMode) var mode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button(action: { self.showingUserInfo.toggle() }) {
                    Image(systemName: "person.crop.circle")
                        .imageScale(.large)
                        .padding()
                }
            }
            HStack {
                EditButton()
                Spacer()
                if self.mode?.wrappedValue == .active {
                    Button("Cancel") {
                        self.editCancelled = true
                        self.draftLocation = self.session.setup.location
                        self.mode?.animation().wrappedValue = .inactive
                    }
                }
            }.padding()
            Form {
                Section(header: Text("Profile").bold()) {
                    Text(session.currentUsername).bold()
                    if session.setup.gateways.count > 0 {
                        Text("Gateway \(session.setup.gateways[0].gatewayId)")
                    }
                    if session.isDemo {
                        Text("No server, using demo file")
                    } else {
                        Text("Server \(session.selectedServer.description)")
                    }
                }
            }.frame(height: 170)
            if self.mode?.wrappedValue == .inactive {
                LocationEditor(location: .constant(session.setup.location))
                    .frame(height: 250)
            } else {
                LocationEditor(location: self.$draftLocation)
                    .frame(height: 250)
                    .onAppear {
                        self.draftLocation = self.session.setup.location
                    }
                    .onDisappear {
                        if self.editCancelled == true {
                            self.editCancelled = false
                        } else {
                            self.session.setup.location = self.draftLocation
                        }
                    }
            }
            VStack(alignment: .leading) {
                Toggle(isOn: $session.didShowVictory) {
                    Text("Show Victory")
                }
                Toggle(isOn: $session.soundEnabled) {
                    Text("Play sounds")
                }
                Button(action: {
                    // Delay call to allow for presented sheet to be dismissed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.session.close()
                    }
                    self.showingUserInfo.toggle()
                    self.isContactingServer = true
                    self.message = "Connecting to the server..."
                }) {
                    HStack {
                        Image(systemName: isContactingServer ? "clock" : "arrow.right.circle")
                            .imageScale(.large)
                        Text("Logout")
                    }
                }

            }.padding()
        }
        .disabled(isContactingServer)
    }
}

struct UserInfoFrame_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoFrame(showingUserInfo: .constant(true)).environmentObject(Session.demoSession)
    }
}
