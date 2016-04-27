//
//  FunctionGenerator.swift
//  Sinewave
//
//  Created by Dan Appel on 4/26/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Darwin

struct FunctionGenerator: GeneratorType, SequenceType {

    let function: Double -> Double

    private var curr = 0.0

    let start: Double
    let diff: Double
    let end: Double

    init(start: Double = 0.0, end: Double, diff: Double, function: Double -> Double) {
        self.start = start
        self.end = end
        self.diff = diff
        self.function = function
    }

    mutating func next() -> (x: Double, y: Double)? {
        guard curr < end else { return nil }
        defer { curr += diff }
        return (Double(curr), function(Double(curr)))
    }
}
