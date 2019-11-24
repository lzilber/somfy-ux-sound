//
//  Jukebox.swift
//  bellz
//
//  Created by Laurent ZILBER on 03/11/2019.
//  Copyright © 2019 zebre.org. All rights reserved.
//

import Foundation
import AVFoundation

class Jukebox {
 
    static let instance: Jukebox = {
        return Jukebox()
    } ()
    
    var player: AVAudioPlayer?
    
    func play(filename: String) {
        let path = Bundle.main.path(forResource: filename, ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    func playVictory() {
        play(filename: "smw_bossvict_arr.mp3")
    }
    
    func playLowNote() {
        play(filename: "Note1.wav")
    }
    
    func playHighNote() {
        play(filename: "Note8.wav")
    }
    
    func playGlass() {
        play(filename: "Glass.aiff")
    }
}
