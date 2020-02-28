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

    @State var selectedURL: ServerURL = .initialValue
    
    let publisher = NotificationCenter.default.publisher(for: Session.loginFailed)
        .map { notification in
            return notification.userInfo?["error"] as! String
        }
        //.print("DEBUG Login notification")
        .receive(on: RunLoop.main)


    var body: some View {
        NavigationView {

        VStack(alignment: .leading, spacing: 20) {
            Form {
                Section(header: Text("Login")) {
                    TextField("Username", text: $login)
                        .textContentType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle.init())
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle.init())
                    Text(verbatim: message).font(.caption)
//                }
//                Section {
                    Button(action: {
                        self.userSession.open(username: self.login, password: self.password, serverURL: self.selectedURL)
                        self.isContactingServer = true
                        self.message = "Connecting to the server..."
                    }) {
                        HStack {
                            Image(systemName: isContactingServer ? "clock" : "arrow.right.circle")
                                .imageScale(.large)
                            Text("Login")
                        }
                    }
                    Spacer()
                }
                Section(header: Text("Advanced")) {
                    List {
                        NavigationLink(
                            destination: ServerSelector(selectedURL: $selectedURL)
                        ) {
                            Text("Server").font(.caption)
                        }
                        Button("Demo") {
                            self.userSession.openDemo()
                        }.font(.caption)
                    }
                }
            }
            .disabled(isContactingServer)
            .onReceive(publisher) { (error_msg) in
                self.isContactingServer = false
                self.message = "An error occured: \(error_msg)."
            }
        }
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login().environmentObject(Session())
    }
}
