//
//  ContentView.swift
//  bellz
//
//  Created by Laurent ZILBER on 22/10/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userSession: Session

    var body: some View {
        VStack {
            if userSession.authenticated {
                Home()
            } else {
                Login()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Session.demoSession)
    }
}
