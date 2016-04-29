//
//  MainViewController.swift
//  Sinewave
//
//  Created by Dan Appel on 4/29/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    var sinewaveViewControllers = [SinewaveViewController]()
    @IBOutlet weak var sinewaveView: SinewaveView!

    lazy var sinFunction: Double -> Double = { x in
        let functions = self.sinewaveViewControllers.map { $0.sinFunction }
        let y = functions.reduce(0) { $0 + $1(x) }
        return y
    }

    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSinewaveVC" {
            let vc = segue.destinationController as! SinewaveViewController
            vc.delegate = self
            sinewaveViewControllers.append(vc)
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window!.delegate = self
    }
}

extension MainViewController: SinewaveViewControllerDelegate {
    func redraw() {

        let points = 0.0.stride(through: Double(view.frame.width), by: 0.2)
            .map { (x: $0, y: self.sinFunction($0)) }

        sinewaveView.points = points
    }
}

extension MainViewController: NSWindowDelegate {
    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
        self.redraw()
        return frameSize
    }
}
