//
//  Note.swift
//  Sinewave
//
//  Created by Dan Appel on 5/5/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

struct Note {
    let frequency: Double
    let amplitude: Double
    let from: Double
    let to: Double
}

extension Note {
    func modify(frequency frequency: Double? = nil, amplitude: Double? = nil, from: Double? = nil, to: Double? = nil) -> Note {
        return self.dynamicType.init(
            frequency: frequency ?? self.frequency,
            amplitude: amplitude ?? self.amplitude,
            from: from ?? self.from,
            to: to ?? self.to
        )
    }
}

extension Note {
    func makeDateRange() -> ClosedInterval<Double> {
        return from...to
    }
}
