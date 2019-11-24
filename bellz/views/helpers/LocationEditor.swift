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
    
    @Binding var location: Location
    @Environment(\.editMode) var mode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
        }
    }
}

struct LocationEditor_Previews: PreviewProvider {
    static var previews: some View {
        LocationEditor(location: .constant(Session.demoSession.setup.location))
    }
}
