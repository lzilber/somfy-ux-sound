//
//  UserSession.swift
//  bellz
//
//  Created by Laurent ZILBER on 22/10/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import Combine
import SwiftUI

final class UserSession: Session, ObservableObject {
    @Published var authenticated = false
}

extension Setup: ObservableObject {
    
}


