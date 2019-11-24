//
//  Victory.swift
//  bellz
//
//  Created by Laurent ZILBER on 03/11/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import SwiftUI

struct Victory: View {
    
    @Environment(\.presentationMode) var presentationMode
    var message: String = "a victory message"
    
    var body: some View {
        VStack {
            Text("Congratulations!").fontWeight(.heavy)
            Image(systemName: "star.fill").foregroundColor(.yellow)
            Text(message).padding()
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Yeah!")
            }.padding()
        }
        .onAppear {
            Jukebox.instance.playVictory()
        }
    }
}

struct Victory_Previews: PreviewProvider {
    static var previews: some View {
        Victory()
            .previewLayout(.fixed(width: 300, height: 300))

    }
}
