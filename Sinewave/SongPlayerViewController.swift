//
//  SongPlayerViewController.swift
//  Sinewave
//
//  Created by Dan Appel on 5/11/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Cocoa

final class Box<T> {
    let value: T
    init(_ value: T) { self.value = value }
}

class SongPlayerViewController: NSViewController {

    @IBOutlet weak var sinewaveView: SinewaveView!
    var notes: [Note]!

    override func viewDidAppear() {
        self.playNotes()
    }

    var currentNotes = [Box<Note>]() {
        didSet {
            redraw()
        }
    }

    func playNotes() {
        let absolute = CFAbsoluteTimeGetCurrent()
        for note in notes {
            let player = FunctionPlayer()
            player.amplitude = note.amplitude
            player.frequency = note.frequency

            let boxed = Box(note)

            NSTimer.at(time: absolute + note.from) { [weak self] in
                guard let sself = self else { return }
                player.start()
                sself.currentNotes.append(boxed)
            }
            NSTimer.at(time: absolute + note.to + 0.05) { [weak self] in
                guard let sself = self else { return }
                player.stop()
                guard let index = sself.currentNotes.indexOf({ $0 === boxed }) else { return }
                sself.currentNotes.removeAtIndex(index)
            }
        }
    }

    func redraw() {
        let notes = currentNotes.map { $0.value }

        let functions = notes.map(sinFunctionForNote)

        let xPoints = 0.0.stride(through: Double(view.frame.width), by: 0.2)

        let points = xPoints.map { x in
            (x: x, y: functions.reduce(0) { $0 + $1(x) })
        }

        sinewaveView.points = points
    }

    func sinFunctionForNote(note: Note) -> Double -> Double {
        return { x in
            return note.amplitude * sin(x * 2*M_PI * note.frequency/44100)
        }
    }
}
