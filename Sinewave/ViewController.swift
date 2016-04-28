//
//  ViewController.swift
//  Sinewave
//
//  Created by Dan Appel on 4/26/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Cocoa
import AVFoundation

class SinewaveViewController: NSViewController {

    lazy var player: FunctionPlayer = FunctionPlayer(thetaFunction: self.thetaFunction)

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

    let thetaFunction: (frequency: Double, sampleRate: Double) -> Double = { frequency, sampleRate in
        return 2*M_PI * frequency/sampleRate
    }

    lazy var sinFunction: Double -> Double = { x in
        // creates reference cycle, but thats OK ;)

        // f(x) = amplitude * sin(sample * 2pi * (freq/samplerate))
        return self.volume * sin(Double(x) * self.thetaFunction(frequency: self.frequency, sampleRate: 44100))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.player.start()

        self.updateSinewaveView()
        self.updateSoundPlayer()
    }

    @IBAction func frequencySliderChanged(slider: NSSlider) {
        print(slider.doubleValue)
        self.frequency = slider.doubleValue
    }

    @IBAction func volumeSliderChanged(slider: NSSlider) {
        self.volume = slider.doubleValue
    }
}

//MARK: Updating views
extension SinewaveViewController {
    func updateSoundPlayer() {
        player.amplitude = self.volume
        player.frequency = self.frequency
    }

    func updateSinewaveView() {

        let points = 0.0.stride(through: Double(view.frame.width), by: 0.2)
            .map { (x: $0, y: sinFunction($0)) }

        sinewaveView.points = points
    }
}
