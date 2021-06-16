//
//  CategoryLogo.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 16/10/2019.
//  Copyright © 2019 noion. All rights reserved.
//

import SwiftUI

struct CategoryLogo: View {
    var category: DeviceCategory
    var body: some View {
        lookupIcon()
    }
    
    fileprivate func lookupIcon() -> Image {
        // FIXME
        switch category.type {
        case .alarm:
            return Image(systemName: "bell")
        case .blinds:
            return Image(systemName: "rectangle")
        case .curtain:
            return Image(systemName: "rectangle.split.3x1")
        case .electrical:
            return Image(systemName: "bolt.horizontal")
        case .light:
            return Image(systemName: "lightbulb")
        case .network:
            return Image(systemName: "skew")
        case .outlet :
            return Image(systemName: "bolt")
        case .gateway:
            return Image(systemName: "cube")
        case .remote_control:
            return Image(systemName: "keyboard")
        case .switch_onoff:
            return Image(systemName: "power")
        case .shutter:
            return Image(systemName: "rectangle.grid.1x2")
        case .technical:
            return Image(systemName: "wrench")
        case .sensor:
            return Image(systemName: "message")
        default:
            return Image(systemName: "questionmark.diamond")
        }
    }
}

struct CategoryLogo_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryLogo(category: DeviceCategoryCatalog.instance.lookup(type: .blinds))
            CategoryLogo(category: DeviceCategoryCatalog.instance.lookup(type: .light))
            CategoryLogo(category: DeviceCategoryCatalog.instance.lookup(type: .outlet))
        }
            .previewLayout(.fixed(width: 44, height: 44)) 
    }
}
