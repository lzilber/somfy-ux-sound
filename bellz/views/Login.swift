//
//  Login.swift
//  bellz
//
//  Created by Laurent ZILBER on 22/10/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import SwiftUI

struct Login: View {
    @State private var login: String = "zigbee@somfy.com"
    @State private var password: String = ""
    @State private var message: String = "Enter login credentials"
    @State private var isContactingServer: Bool = false
    
    @EnvironmentObject var userSession: Session

    @State private var selectedCloud: Cloud = ServerURL.default.cloud
    @State private var selectedServer: Server = ServerURL.default.server
    @State var selectedURL: ServerURL = .default
    
    let publisher = NotificationCenter.default.publisher(for: Session.loginFailed)
        .map { notification in
            return notification.userInfo?["error"] as! String
        }
        //.print("DEBUG Login notification")
        .receive(on: RunLoop.main)


    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Form {
                Section(header: Text("Login").bold()) {
                    TextField("Username", text: $login)
                        .textContentType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle.init())
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle.init())
                }
                Section(header: Text("Server")) {
                    Picker(selection: $selectedCloud, label: Text("")) {
                        ForEach(Cloud.allValues) { v in
                            Text(v.rawValue).tag(v)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Picker(selection: $selectedServer, label: Text("")) {
                        ForEach(Server.allValues) { v in
                            Text(v.rawValue).tag(v)
                            
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Text(verbatim: message).fontWeight(.light).italic()
                    }
                Section {
                    Button(action: {
                        // FIXME
                        // Il doit etre possible de ne passer que des Bindings (login, pwd, url) et pas la session, et c'est le parent qui fait le openSession ?
                        self.userSession.open(username: self.login, password: self.password, serverURL: ServerURL(cloud: self.selectedCloud, server: self.selectedServer))
                        self.isContactingServer = true
                        self.message = "Connecting to the server..."
                    }) {
                        HStack {
                            Image(systemName: isContactingServer ? "clock" : "arrow.right.circle")
                                .imageScale(.large)
                            Text("Login")
                        }
                    }
                }
            }
            .disabled(isContactingServer)
            .onReceive(publisher) { (error_msg) in
                self.isContactingServer = false
                self.message = "An error occured: \(error_msg)."
            }
            Spacer()
            Button("Demo") {
                self.userSession.openDemo()
            }
        }
    }
    
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login().environmentObject(Session())
    }
}
