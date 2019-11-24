//
//  OverkizServers.swift
//  MyOverkiz
//
//  Created by Laurent ZILBER on 27/09/2017.
//  Copyright © 2017 noion. All rights reserved.
//

import Foundation

enum Cloud: String, Identifiable {
    
    case Europe, Asia, China, America
    static let allValues: [Cloud] = [.Asia, .Europe, .China, .America]
    
    var id: Cloud {self}  // for SwiftUI ForEach

}

enum Server: String, Identifiable
{
    case Dev, Preprod, Prod
    static let allValues: [Server] = [.Dev, .Preprod, .Prod]
    
    var id: Server {self}  // for SwiftUI ForEach
}

public struct ServerURL {
    let cloud: Cloud
    let server: Server
    
    static public let `default` = Self(cloud: .Asia, server: .Dev)
    
    var nickname: String {
        switch cloud {
        case .Europe:
            switch server {
                case .Dev: return "std5"
                case .Preprod: return "ha102"
                case .Prod: return "ha101"
            }
        case .Asia:
            switch server {
            case .Dev: return "std101"
            case .Preprod: return "ha202"
            case .Prod: return "ha201"
            }
        case .China:
            switch server {
            case .Dev: return "std104"
            case .Preprod: return "std202"
            case .Prod: return "std201"
            }
        case .America:
            switch server {
            case .Dev: return "std301"
            case .Preprod: return "ha402"
            case .Prod: return "ha401"
            }
        }
    }
    
    var url: String {
        return "https://\(nickname)-1.overkiz.com/enduser-mobile-web/enduserAPI"
    }
    
    var description: String {
        return "\(cloud) \(server) [\(nickname)]"
    }
}

