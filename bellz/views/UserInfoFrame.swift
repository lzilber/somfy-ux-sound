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
    
    var body: some View {
        NavigationView {

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if session.setup.gateways.count > 0 {
                    GatewayAlive(gateway: session.setup.gateways[0])
                }
                Spacer()
                Button(action: { self.showingUserInfo.toggle() }) {
                    Image(systemName: "person.crop.circle")
                        .imageScale(.large)
                        .padding()
                }
            }
            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        Text("User")
                        Spacer()
                        Text(session.currentUsername)
                    }
                    if session.setup.gateways.count > 0 {
                        HStack {
                            Text("Gateway")
                            Spacer()
                            Text(session.setup.gateways[0].gatewayId)
                        }
                    }
                    if session.isDemo {
                        Text("No server, using demo file")
                    } else {
                        HStack {
                            Text("Server")
                            Spacer()
                            Text(session.selectedServer.description)
                        }
                    }
                    NavigationLink(
                        destination: LocationEditor(location: $session.setup.location)
                    ) {
                        Text("Location (\(session.setup.location.city)...)")
                    }
                }
            }
            //.frame(height: 170)
//            if self.mode?.wrappedValue == .inactive {
//                LocationEditor(location: .constant(session.setup.location))
//                    .frame(height: 250)
//            } else {
//                LocationEditor(location: self.$draftLocation)
//                    .frame(height: 250)
//                    .onAppear {
//                        self.draftLocation = self.session.setup.location
//                    }
//                    .onDisappear {
//                        if self.editCancelled == true {
//                            self.editCancelled = false
//                        } else {
//                            self.session.setup.location = self.draftLocation
//                        }
//                    }
//            }
            VStack(alignment: .leading) {
                Toggle(isOn: $session.didShowVictory) {
                    Text("Show Victory")
                }
                Toggle(isOn: $session.soundEnabled) {
                    Text("Play sounds")
                }
                Spacer()
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
}

struct UserInfoFrame_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoFrame(showingUserInfo: .constant(true)).environmentObject(Session.demoSession)
    }
}
