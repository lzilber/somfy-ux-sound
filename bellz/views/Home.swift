//
//  Home.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 16/10/2019.
//  Copyright © 2019 noion. All rights reserved.
//

import SwiftUI

struct Home: View {

    @EnvironmentObject var session: Session
    
    @State var showingUserInfo = false
    var userButton: some View {
        Button(action: { self.showingUserInfo.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .padding()
        }
    }
    var body: some View {
        NavigationView {
            List {
                // TODO Favorites
                // Categories
                ForEach(session.setup.categories) { category in
                    NavigationLink(destination: DeviceList(devices: self.session.setup.devices.filter({
                        return $0.category == category
                    }))) {
                        CategoryRow(category: category)
                    }
                }
                // See all
                NavigationLink(destination: DeviceList(devices: session.setup.devices)) {
                    Text("See All")
                }
            }
            .navigationBarTitle(Text("Setup"))
            .navigationBarItems(trailing: userButton)
            .sheet(isPresented: $showingUserInfo) {
                UserInfoFrame(showingUserInfo: self.$showingUserInfo)
                    .environmentObject(self.session)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(Session.demoSession)
    }
}
