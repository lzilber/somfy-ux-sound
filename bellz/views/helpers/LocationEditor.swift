//
//  LocationEditor.swift
//  bellz
//
//  Created by Laurent ZILBER on 07/11/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import SwiftUI
import Combine

struct LocationEditor: View {
    
    @EnvironmentObject var session: Session
    @Binding var location: Location
    @State private var previousLocation: Location = Location()

    @Environment(\.editMode) var mode
    @State private var locationEdited = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                EditButton()
                Spacer()
                if self.mode?.wrappedValue == .active {
                    Button("Save") {
                        self.session.saveLocation()
                        self.locationEdited = true
                        self.mode?.animation().wrappedValue = .inactive
                    }
                }
            }.padding([.horizontal])
            Form {
                Section(header: Text("Location").bold()) {
                    TextField("Address", text: $location.addressLine1)
                        .textContentType(.streetAddressLine1)
                    TextField("City", text: $location.city)
                        .textContentType(.addressCity)
                    TextField("Postal code", text: $location.postalCode)
                        .textContentType(.postalCode)
                    TextField("Country", text: $location.country)
                        .textContentType(.countryName)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle.init())
                .disabled(self.mode?.wrappedValue == .inactive)
            }
            .onAppear {
                self.previousLocation = self.location
            }
            .onDisappear {
                if self.locationEdited == true {
                    self.locationEdited = false
                } else {
                    self.location = self.previousLocation
                }
            }
        }
    }
}

struct LocationEditor_Previews: PreviewProvider {
    static var previews: some View {
        LocationEditor(location: .constant(Session.demoSession.setup.location))
            .environment(\.editMode, .constant(.active))
            .environmentObject(Session.demoSession)
            .previewLayout(.fixed(width: 300, height: 300))

    }
}
