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

    let player = FunctionPlayer()

    var volume: Double = 1 {
        didSet {
            self.updateSinewaveView()
            self.playSound()
        }
    }
    var frequency: Double = 441 {
        didSet {
            self.updateSinewaveView()
            self.playSound()
        }
    }

    lazy var sinFunction: Double -> Double = { x in
        // f(x) = vol * sin(x * 2pi * (freq/samplerate))
        return self.volume * sin(Double(x) * (2 * M_PI) * (self.frequency / 44100))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateSinewaveView()
        self.playSound()
    }

    func playSound() {
        let function = FunctionGenerator(end: 100, diff: 1, function: sinFunction)
        player.play(function: function)
    }

    func updateSinewaveView() {
        let function = FunctionGenerator(
            end: Double(sinewaveView.frame.width),
            diff: 0.5,
            function: sinFunction)

        let points = Array(function)
        sinewaveView.points = points
    }

    @IBAction func frequencySliderChanged(slider: NSSlider) {
        self.frequency = slider.doubleValue
    }
    @IBAction func volumeSliderChanged(slider: NSSlider) {
        self.volume = slider.doubleValue
    }
}
