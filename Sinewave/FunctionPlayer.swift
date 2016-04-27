//
//  FunctionPlayer.swift
//  Sinewave
//
//  Created by Dan Appel on 4/26/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import AVFoundation

final class FunctionPlayer {
    let engine: AVAudioEngine
    let player: AVAudioPlayerNode
    let mixer: AVAudioMixerNode

    init() {
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        mixer = engine.mainMixerNode
        engine.attachNode(player)
    }

    func play(function function: FunctionGenerator) {

        let size = Int(function.end)

        let buffer = AVAudioPCMBuffer(PCMFormat: mixer.outputFormatForBus(0), frameCapacity: UInt32(size))
        buffer.frameLength = AVAudioFrameCount(100)

        for (x, y) in function {
            buffer.floatChannelData.memory[Int(x)] = Float(y)
        }

        try! engine.start()

        engine.connect(player, to: mixer, format: mixer.outputFormatForBus(0))
        player.scheduleBuffer(buffer, atTime: nil, options: .Loops, completionHandler: nil)
        player.play()
    }
}


