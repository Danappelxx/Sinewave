//
//  Note.swift
//  Sinewave
//
//  Created by Dan Appel on 5/5/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

struct Note {
    let frequency: Double
    let amplitude: Double = 1.0
    let from: Double
    let to: Double
}

extension Note {
    func makeRange() -> ClosedInterval<Double> {
        return from...to
    }
}
