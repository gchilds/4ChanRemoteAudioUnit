//
//  FourChanAudioEngine.swift
//  4-chan-ipadpro
//
//  Created by Gordon Childs on 9/12/2015.
//  Copyright © 2015 Gordon Childs. All rights reserved.
//

import AVFoundation

class FourChanAudioEngine {
//	var engine = AVAudioEngine()

	func doSomething () {
		// var so I can take its address as a UnsafePointer<>
		var desc = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_RemoteIO, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)

		let comp = AudioComponentFindNext(nil, &desc)
		
		var au = AudioComponentInstance()
		let err = AudioComponentInstanceNew(comp, &au)
		
		assert(err == noErr, "was hoping for success")

	}
	
}