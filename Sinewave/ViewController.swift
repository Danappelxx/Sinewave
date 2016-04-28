//
//  ViewController.swift
//  Sinewave
//
//  Created by Dan Appel on 4/26/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var sinewaveView: SinewaveView!

    var volume: Double = 1 {
        didSet {
            self.updateSinewaveView()
            self.updateSoundPlayer()
        }
    }
    var frequency: Double = 441 {
        didSet {
            self.updateSinewaveView()
            self.updateSoundPlayer()
        }
    }

    lazy var sinFunction: Double -> Double = { x in // creates reference cycle, but thats OK ;)
        // f(x) = vol * sin(x * 2pi * (freq/samplerate))
        return self.volume * sin(Double(x) * (2 * M_PI) * (self.frequency / 44100))
    }

    lazy var player: FunctionPlayer = FunctionPlayer(function: self.soundFunction)

    // from 0 to width by 512 (should not be hardcoded), using sinFunction
    lazy var soundFunction: FunctionGenerator = FunctionGenerator(
        end: 512,
        diff: 1,
        function: self.sinFunction)

    // from 0 to width by 0.5, using sinFunction
    lazy var drawFunction: FunctionGenerator = FunctionGenerator(
        end: Double(self.sinewaveView.frame.width),
        diff: 0.5,
        function: self.sinFunction)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateSinewaveView()
        self.updateSoundPlayer()
        NSApp.windows.first?.delegate = self
    }

    @IBAction func frequencySliderChanged(slider: NSSlider) {
        self.frequency = slider.doubleValue
    }

    @IBAction func volumeSliderChanged(slider: NSSlider) {
        self.volume = slider.doubleValue
    }
}

//MARK: Updating views
extension ViewController {
    func updateSoundPlayer() {
        player.frequency = Float(self.frequency)
        player.amplitude = Float(self.volume)
    }

    func updateSinewaveView() {
        let points = Array(drawFunction)
        sinewaveView.points = points
    }
}

//MARK: Resize detection
extension ViewController: NSWindowDelegate {
    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
        let old = self.drawFunction
        self.drawFunction = FunctionGenerator(
            start: old.start,
            end: Double(frameSize.width),
            diff: old.diff,
            function: old.function)
        self.updateSinewaveView()
        return frameSize
    }
}
