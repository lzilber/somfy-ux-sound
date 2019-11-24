//
//  CategoryRow.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 17/10/2019.
//  Copyright © 2019 noion. All rights reserved.
//

import SwiftUI

struct CategoryRow: View {
    var category: DeviceCategory
    var body: some View {
        HStack {
            CategoryLogo(category: category)
                .frame(width: 40, height: 40)
            Text(verbatim: category.name)
            Spacer()
        }
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryRow(category: DeviceCategoryBlinds)
            CategoryRow(category: DeviceCategoryOutlet)
        }
        .previewLayout(.fixed(width: 300, height: 44))
    }
}
