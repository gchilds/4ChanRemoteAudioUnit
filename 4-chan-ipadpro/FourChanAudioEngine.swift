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
//	var engine = AVAudioEngine()

	func doSomething () {
		// var so I can take its address as a UnsafePointer<>
		var desc = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_RemoteIO, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)

		let comp = AudioComponentFindNext(nil, &desc)
		
		var au = AudioComponentInstance()	// var for UnsafeMutablePointer-ness
		var err = AudioComponentInstanceNew(comp, &au)
		assert(err == noErr, "was hoping for success")

		// TODO: SO is there a better way to write this?
		let inputProc: @convention(c) (UnsafeMutablePointer<Void>, UnsafeMutablePointer<AudioUnitRenderActionFlags>, UnsafePointer<AudioTimeStamp>, UInt32, UInt32, UnsafeMutablePointer<AudioBufferList>) -> OSStatus = {
			(a, b, c, d, e, f) -> OSStatus in
			
			return noErr
		}
		
		
		var input = AURenderCallbackStruct(inputProc: inputProc, inputProcRefCon: UnsafeMutablePointer(Unmanaged.passUnretained(self).toOpaque()))

		let speakerBus = UInt32(0)

		// TODO: generic
		err = AudioUnitSetProperty(au, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input,
		speakerBus /* speaker bus */, &input, UInt32(sizeof(AURenderCallbackStruct)))
		assert(err == noErr, "was hoping for success")
		
		let numChans = UInt32(2)
		let bits = UInt32(32)
		let frameSize = numChans*bits/8

		var streamFormat = AudioStreamBasicDescription(mSampleRate: 48000, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsFloat, mBytesPerPacket: frameSize, mFramesPerPacket: 1, mBytesPerFrame: frameSize, mChannelsPerFrame: numChans, mBitsPerChannel: bits, mReserved: 0)
		
		
		err = AudioUnitSetProperty(au, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, speakerBus, &streamFormat, UInt32(sizeof(AudioStreamBasicDescription)))
		assert(err == noErr, "was hoping for success")
		
		err = AudioUnitInitialize(au)
		assert(err == noErr, "was hoping for success")
		
		err = AudioOutputUnitStart(au)
		assert(err == noErr, "was hoping for success")
	}
	
}