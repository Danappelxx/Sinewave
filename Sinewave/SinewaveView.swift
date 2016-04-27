//
//  SinewaveView.swift
//  Sinewave
//
//  Created by Dan Appel on 4/26/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Cocoa

class SinewaveView: NSView {

    var points = [(x: Double, y: Double)]() {
        didSet {
            self.needsDisplay = true
        }
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        NSColor.whiteColor().setFill()
        NSRectFill(dirtyRect)

        let bezierPaths = points
            .map(normalize)
            .map(offset)
            .map(CGPoint.init(x:y:))
            .map { NSRect(origin: $0, size: CGSize(width: 5, height: 5)) }
            .map(NSBezierPath.init(ovalInRect:))

        NSColor.darkGrayColor().set()
        bezierPaths.forEach { $0.fill() }
    }

    func offset(x: Double, y: Double) -> (x: Double, y: Double) {
        let xOffset = 0.0//Double(self.frame.width / 2)
        let yOffset = Double(self.frame.height / 2)

        return (x + xOffset, y + yOffset)
    }

    func normalize(x: Double, y: Double) -> (x: Double, y: Double) {
        return (x, y * 30)
    }
}
