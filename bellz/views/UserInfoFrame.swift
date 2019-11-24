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
                Button("Cancel") {
                    if self.mode?.wrappedValue == .inactive {
//                        self.showingUserInfo = false
                    } else {
                        self.mode?.animation().wrappedValue = .inactive
                    }
                }
                Spacer()
                EditButton()
            }.padding()
            Form {
                Section(header: Text("Profile").bold()) {
                    Text(session.currentUsername).bold()
                    Text("Gateway \(session.setup.gateways[0].gatewayId)")
                    if session.isDemo {
                        Text("No server, using demo file")
                    } else {
                        Text("Server \(session.selectedServer.description)")
                    }
                }
            }.frame(height: 170)

            LocationEditor(location: self.$draftLocation)
                .frame(height: 250)
                .onAppear {
                    self.draftLocation = self.session.setup.location
            }
            .onDisappear {
                // FIXME not called ...
                self.session.setup.location = self.draftLocation
            }
            VStack() {
                Toggle(isOn: $session.didShowVictory) {
                    Text("Show Victory")
                }
                Toggle(isOn: $session.soundEnabled) {
                    Text("Play sounds")
                }
            }.padding()
        }
    }
}

struct UserInfoFrame_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoFrame(showingUserInfo: .constant(true)).environmentObject(Session.demoSession)
    }
}
