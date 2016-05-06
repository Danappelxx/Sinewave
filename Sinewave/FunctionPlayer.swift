//
//  FunctionPlayer.swift
//  Sinewave
//
//  Created by Dan Appel on 4/26/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import AVFoundation

final class FunctionPlayer {

    private(set) var outputInstance: AudioComponentInstance

    var theta = 0.0
    var frequency = 441.0
    var amplitude = 1.0
    let sampleRate = 44100.0

    let renderTone: AURenderCallback = {
        (passedData: UnsafeMutablePointer<Void>,
        ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        timeStamp: UnsafePointer<AudioTimeStamp>,
        busNumber: UInt32,
        frames: UInt32,
        ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus in

        let player = unsafeBitCast(passedData, FunctionPlayer.self)

        let buffer = UnsafeMutablePointer<Float32>(ioData.memory.mBuffers.mData)

        var theta = player.theta

        let increment = SinewaveViewController.theta(frequency: player.frequency, sampleRate: player.sampleRate)

        //TODO: Move this logic to the sin function in ViewController
        for frame in 0..<Int(frames) {
            buffer[frame] = Float32(sin(theta) * player.amplitude)

            theta += increment
            if theta > 2*M_PI {
                theta -= 2*M_PI
            }
        }

        player.theta = theta

        return 0
    }

    init() {
        self.outputInstance = nil

        let outputDescription = makeOutputDescription()
        let outputComponent = makeOutputComponent(description: outputDescription)
        self.outputInstance = makeOutputInstance(component: outputComponent)

        setRenderCallback(instance: outputInstance, callback: self.renderTone)
        setStreamFormat(instance: outputInstance)

        AudioUnitInitialize(outputInstance)
    }

    deinit {
        self.stop()
    }

    func makeOutputDescription() -> AudioComponentDescription {
        var outputDescription = AudioComponentDescription()
        outputDescription.componentType = kAudioUnitType_Output;
//        outputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
        outputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        outputDescription.componentFlags = 0;
        outputDescription.componentFlagsMask = 0;
        return outputDescription
    }

    func makeOutputComponent(description description: AudioComponentDescription) -> AudioComponent {
        var description = description
        return AudioComponentFindNext(nil, &description)
    }

    func makeOutputInstance(component component: AudioComponent) -> AudioComponentInstance {
        var outputInstance: AudioComponentInstance = nil
        //TODO: Handle error
        let error = AudioComponentInstanceNew(component, &outputInstance)
        return outputInstance
    }

    func setRenderCallback(instance instance: AudioComponentInstance, callback: AURenderCallback) {

        let selfPointer = UnsafeMutablePointer<Void>(Unmanaged.passUnretained(self).toOpaque())
        var input = AURenderCallbackStruct(inputProc: callback, inputProcRefCon: selfPointer)

        //TODO: Handle error
        let error = AudioUnitSetProperty(
            instance, // unit
            kAudioUnitProperty_SetRenderCallback, // id
            kAudioUnitScope_Input, // scope
            0, // element
            &input, // data
            UInt32(sizeof(AURenderCallbackStruct))) // data size
    }

    func setStreamFormat(instance instance: AudioComponentInstance) {

        var streamFormat = AudioStreamBasicDescription()
        streamFormat.mSampleRate = 44100
        streamFormat.mFormatID = kAudioFormatLinearPCM
        streamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
        streamFormat.mBytesPerPacket = 4; // 4 bytes for 'float'
        streamFormat.mBytesPerFrame = 4; // sizeof(float) * 1 channel
        streamFormat.mFramesPerPacket = 1; // 1 channel
        streamFormat.mChannelsPerFrame = 1; // 1 channel
        streamFormat.mBitsPerChannel = 8 * 4; // 1 channel * 8 bits/byte * sizeof(float)

        //TODO: Handle error
        let error = AudioUnitSetProperty(
            instance, // unit
            kAudioUnitProperty_StreamFormat, // id
            kAudioUnitScope_Input, // scope
            0, // element
            &streamFormat, // data
            UInt32(sizeof(AudioStreamBasicDescription))) // data size
    }

    func start() {
        AudioOutputUnitStart(outputInstance)
    }

    func stop() {
        AudioOutputUnitStop(outputInstance)
    }
}
