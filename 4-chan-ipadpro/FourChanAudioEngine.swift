//
//  FourChanAudioEngine.swift
//  4-chan-ipadpro
//
//  Created by Gordon Childs on 9/12/2015.
//  Copyright © 2015 Gordon Childs. All rights reserved.
//

// TODO: post on codereview
// TODO: better c callback on SO?

import AVFoundation

class FourChanAudioEngine {
	
	let sampleRate = Float64(48000)
	var au = AudioComponentInstance()	// var for UnsafeMutablePointer-ness
	
	var audioIndex = Float64(0)
	
	func generateAudio(abl: AudioBufferList, numberFrames: UInt32) {
		assert(abl.mNumberBuffers == 1)
		let numChannels = abl.mBuffers.mNumberChannels
		let pointer = UnsafeMutablePointer<Float>(abl.mBuffers.mData)
		let arr = UnsafeMutableBufferPointer<Float>(start: pointer, count:Int(numberFrames*numChannels))
		
		for i in 0..<numberFrames {
			for j in 0..<numChannels {
				arr[Int(i*numChannels + j)] = Float(sin(2*M_PI*audioIndex*440*(Float64(j)+1)/sampleRate))
			}
			audioIndex++
		}
	}
	
	func doSomething () {
		let sesh = AVAudioSession.sharedInstance()
		try! sesh.setCategory(AVAudioSessionCategoryPlayback)
		try! sesh.setActive(true)
		
		
		// var so I can take its address as a UnsafePointer<>
		var desc = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_RemoteIO, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
		
		let comp = AudioComponentFindNext(nil, &desc)
		
		var err = AudioComponentInstanceNew(comp, &au)
		assert(err == noErr, "AudioComponentInstanceNew")
		
		// TODO: SO is there a better way to write this?
		let inputProc: @convention(c) (UnsafeMutablePointer<Void>, UnsafeMutablePointer<AudioUnitRenderActionFlags>, UnsafePointer<AudioTimeStamp>, UInt32, UInt32, UnsafeMutablePointer<AudioBufferList>) -> OSStatus = {
			(inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData) -> OSStatus in
			
			let myObject = Unmanaged<FourChanAudioEngine>.fromOpaque(COpaquePointer(inRefCon)).takeUnretainedValue()
			
			myObject.generateAudio(ioData.memory, numberFrames: inNumberFrames)

			return noErr
		}
		
		var input = AURenderCallbackStruct(inputProc: inputProc, inputProcRefCon: UnsafeMutablePointer(Unmanaged.passUnretained(self).toOpaque()))
		
		let speakerBus = UInt32(0)
		
		// TODO: generic
		err = AudioUnitSetProperty(au, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input,
			speakerBus, &input, UInt32(sizeof(AURenderCallbackStruct)))
		assert(err == noErr, "AudioUnitSetProperty: render callback")
		
		let numChans = UInt32(2)
		let bits = UInt32(32)
		let frameSize = numChans*bits/8
		
		var streamFormat = AudioStreamBasicDescription(mSampleRate: sampleRate, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kLinearPCMFormatFlagIsFloat, mBytesPerPacket: frameSize, mFramesPerPacket: 1, mBytesPerFrame: frameSize, mChannelsPerFrame: numChans, mBitsPerChannel: bits, mReserved: 0)
		
		
		err = AudioUnitSetProperty(au, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, speakerBus, &streamFormat, UInt32(sizeof(AudioStreamBasicDescription)))
		assert(err == noErr, "AudioUnitSetProperty: stream format")
		
		err = AudioUnitInitialize(au)
		assert(err == noErr, "AudioUnitInitialize")
		
		err = AudioOutputUnitStart(au)
		assert(err == noErr, "AudioOutputUnitStart")
	}
	
}