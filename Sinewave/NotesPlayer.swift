//
//  NotesPlayer.swift
//  Sinewave
//
//  Created by Dan Appel on 5/11/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Foundation

struct NotesPlayer {

    let notes: [Note]

    func play() {
        for note in notes {
            let player = FunctionPlayer()
            player.amplitude = note.amplitude
            player.frequency = note.frequency

            NSTimer.after(note.from - 0.05) {
                player.start()
            }
            NSTimer.after(note.to) {
                player.stop()
            }
        }
    }
}
