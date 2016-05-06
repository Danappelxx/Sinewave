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
        guard !self.sinewaveViewControllers.isEmpty else { return 0 }

        let y = self.sinewaveViewControllers
            .map { $0.sinFunction }
            .reduce(0) { $0 + $1(x) }

        return y / Double(self.sinewaveViewControllers.count)
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
        self.redraw()
    }
}

extension MainViewController: SinewaveViewControllerDelegate {
    func redraw() {

        let points = 0.0.stride(through: Double(view.frame.width), by: 0.2)
            .map { (x: $0, y: self.sinFunction($0)) }

        sinewaveView.points = points
    }

    func removeChild(child: SinewaveViewController) {
        guard let index = self.sinewaveViewControllers.indexOf(child) else { return }
        self.sinewaveViewControllers.removeAtIndex(index)
        self.redraw()
    }
}

extension MainViewController: NSWindowDelegate {
    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
        self.redraw()
        return frameSize
    }
}
