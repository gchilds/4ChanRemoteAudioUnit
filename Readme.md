A failed attempt at four channel audio output for the iPadPro using Swift 2 / CoreAudio (3rd and 4th channels are discarded).

It’s an interesting example because it shows how to:

  * output realtime, procedural audio using a CoreAudio `kAudioUnitSubType_RemoteIO` audio unit.
  * cast between `self` and `UnsafeMutablePointer<Void>`
  * implement a c callback via `AURenderCallback`
  * cast `AudioBufferList` `AudioBuffer` to a swift array without accidentally copying (`UnsafeMutableBufferPointer<Float>`)


API calls: `AudioComponentFindNext`, `AudioUnitSetProperty`, `AudioUnitInitialize`, `AudioOutputUnitStart`

Structs/Classes: `AudioComponentDescription`, `AURenderCallbackStruct`, `AudioStreamBasicDescription`, `AVAudioSession`

Constants: `kAudioFormatLinearPCM`, `kLinearPCMFormatFlagIsFloat`, `kAudioUnitProperty_StreamFormat`, `AVAudioSessionCategoryPlayback`