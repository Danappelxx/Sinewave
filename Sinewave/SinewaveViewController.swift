//
//  ViewController.swift
//  Sinewave
//
//  Created by Dan Appel on 4/26/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Cocoa
import AVFoundation

protocol SinewaveViewControllerDelegate: class {
    func redraw()
}

class SinewaveViewController: NSViewController {

    weak var delegate: SinewaveViewControllerDelegate?
    let player = FunctionPlayer()

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

    lazy var sinFunction: Double -> Double = { x in
        // creates reference cycle, but thats OK ;)

        // f(x) = amplitude * sin(sample * 2pi * (freq/samplerate))
        return self.volume * sin(Double(x) * self.dynamicType.theta(frequency: self.frequency, sampleRate: 44100))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.player.start()

        self.updateSinewaveView()
        self.updateSoundPlayer()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window!.delegate = self
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
        self.delegate?.redraw()
    }
}

extension SinewaveViewController {
    static func theta(frequency frequency: Double, sampleRate: Double) -> Double {
        return 2*M_PI * frequency/sampleRate
    }
}

extension SinewaveViewController: NSWindowDelegate {
    func windowShouldClose(sender: AnyObject) -> Bool {
        self.player.stop()
        return true
    }
    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
        updateSinewaveView()
        return frameSize
    }
}
