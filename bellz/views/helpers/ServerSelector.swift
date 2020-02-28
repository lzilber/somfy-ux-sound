//
//  ServerSelector.swift
//  bellz
//
//  Created by Laurent ZILBER on 13/01/2020.
//  Copyright © 2020 zebre.org. All rights reserved.
//

import SwiftUI

struct ServerSelector: View {
    
    @Binding var selectedURL: ServerURL

    var body: some View {
        VStack {
            Picker(selection: $selectedURL.cloud, label: Text("")) {
                ForEach(ServerURL.Cloud.allCases, id: \.self) { cloud in
                    Text(cloud.rawValue).tag(cloud)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            Picker(selection: $selectedURL.server, label: Text("")) {
                ForEach(ServerURL.Server.allCases, id: \.self) { server in
                    Text(server.rawValue).tag(server)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
        }
    }
}

struct ServerSelector_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelector(selectedURL: .constant(ServerURL.initialValue))
            .previewLayout(.fixed(width: 300, height: 160))
    }
}
