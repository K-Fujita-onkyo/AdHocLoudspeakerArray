///
///
///Project name: AdHocLoudspeakerArray
/// Class name: LoudspeakerModel
/// Creator: Kazuki Fujita
/// Update: 2023/11/23 (Thu)
///
/// ---Explanation---
/// Loudspeaker model
///
///

import SwiftUI
import Foundation
import AVFoundation
import NearbyInteraction
import MultipeerConnectivity

class LoudspeakerModel: AdHocModel, ObservableObject {
    @Published var isConnected: String = "Not connected."
    @Published var isStartNISession: String = "Stop NI Session"
    @Published var testText: String = ""
    @Published var testText2: String = ""
    @Published var testText3: String = ""
    @Published var information: LoudspeakerInfoMessage = LoudspeakerInfoMessage(isConvexHull: false, location: simd_float3(x: 0, y: 0, z: 0))
    
    var innerRoom: InnerRoomInfoMessage = InnerRoomInfoMessage(locations: [])
    var outerRoom: OuterRoomInfoMessage = OuterRoomInfoMessage(width: 10, height: 10, wallCoefficient: 0.05)
    let soundPathCalculator: SoundPathModel = SoundPathModel()
    
    @Published var audioEngine: AVAudioEngine = AVAudioEngine()
    let audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!
    
    var audioQueue: [AudioInfoMessage] = []
    var audioLocation: simd_float3 = simd_float3(x: -5, y: 0, z: 10)
    var nodeMaxNum: Int = 3
    
    var test: Int = 1
    
    override init(){
        super.init()
        self.setupNearbyInteraction()
        self.setupAudioPlayer()
        self.playAudio()
    }
    
    func update(){
        test += 1
        //self.testText = String(test)
    }
    
    func updateLoudspeakerLocation(nearbyObject: NINearbyObject){
        
        let niDiscoveryToken: NIDiscoveryToken = nearbyObject.discoveryToken
        let distance: Float! = nearbyObject.distance
        let direction: simd_float3! = nearbyObject.direction
        
        
        if  distance == nil || direction == nil {
            testText3 = "Debug(soModel): Can't measure the location of \(niDiscoveryToken)"
            return
        }
        
//        testText = "OK"
        // FIXME: - This is for simulator values. Please deleted in a real test.
        self.information.location = simd_float3(x: -direction.x*distance, y: direction.y*distance, z: -direction.z*distance)
    }
    
    // MARK: - NISessionDelegate Methods
    
    // Session to to detect movement of other devices
    // Notifies me when the session updates nearby objects.
    override func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        for nearbyObject in nearbyObjects {
            self.updateLoudspeakerLocation(nearbyObject: nearbyObject)
        }
    }
    
    func sessionSuspensionEnd(_ session: NISession) {
        session.run(session.configuration!)
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        self.testText3 = String(error.localizedDescription)
    }
    // MARK: - MCSessionDelegate Methods
    
    // Session to change my state
    // Called when the state of a nearby peer changes.
    // State: connected, notConnected, and connecting
    
    override func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case .connected:
            print("Connected")
            self.isConnected = "Connected!!"
//            self.sendData(data: self.myDiscoveryTokenData, mcPeerID: peerID)
        case .connecting:
            print("Connecting")
            self.isConnected = "Connecting..."
        case .notConnected:
            print("Not connected")
            self.isConnected = "Not connected."
        default:
            print("Other")
        }
    }
    
    // Session to get data
    // Indicates that an NSData object has been received from a nearby peer.
    override func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let loudspeakerInfo = self.convertDataToInstance(type: LoudspeakerInfoMessage.self, data: data){
            self.information = loudspeakerInfo
            self.testText = "loudspeakerInfo"
            return
        }
        
        if let audioInfo = self.convertDataToInstance(type: AudioInfoMessage.self, data: data){
            self.audioQueue.append(audioInfo)
            self.testText = "audioInfo"
            return
        }
        
        if let audioLocationInfo = self.convertDataToInstance(type: AudioLocationInfoMessage.self, data: data){
            self.audioLocation = audioLocationInfo.location
            self.testText2 = String(self.audioLocation.x) + " " + String(self.audioLocation.z)
            self.testText = "audioLocationInfo"
            return
        }
        
        
        if let outerRoomInfo = self.convertDataToInstance(type: OuterRoomInfoMessage.self, data: data){
            self.outerRoom = outerRoomInfo
            
            self.testText = "outerRoom"
            return
        }
        
        if let innerRoomInfo = self.convertDataToInstance(type: InnerRoomInfoMessage.self, data: data){
            self.innerRoom = innerRoomInfo
            self.testText = "innerRoom"
            return
        }
        
        if  let niDiscoveryToken = self.startNISession(niDiscoveryTokenData: data){
            self.sendData(data: self.myDiscoveryTokenData, mcPeerID: peerID)
            self.isStartNISession = "StartNISession"
            self.information.isConvexHull = true
            self.testText = "niSession"
            return
        }
    }
    
    func setupAudioPlayer(){
        self.audioEngine.attach(self.audioPlayerNode)
        self.audioEngine.connect(self.audioPlayerNode, to: self.audioEngine.mainMixerNode, format: self.format)
    }
    
    func playAudio(){
        do {
            try self.audioEngine.start()
            self.audioPlayerNode.play()
        } catch let error {
          print(error)
        }
    }
    
    func playAudioFromFloatArray(floatArray: [Float]) {

        let buffer = AVAudioPCMBuffer(pcmFormat: self.format, frameCapacity: AVAudioFrameCount(floatArray.count))!
        buffer.frameLength = AVAudioFrameCount(floatArray.count)
        let audioBuffer = buffer.floatChannelData![0]
        for i in 0..<floatArray.count {
            audioBuffer[i] = floatArray[i]
        }
        self.audioPlayerNode.scheduleBuffer(buffer) {
        }
    }
    
    
    
    func spatializeSoundInRealTime(){
        
        if self.audioQueue.isEmpty {
            return
        }
        
        if self.audioEngine.attachedNodes.count > self.nodeMaxNum {
            return
        }
        
        let audioInfo = self.audioQueue.removeFirst()
        
        let soundPath = self.soundPathCalculator.calcSoundPath(
            soundFloatArray: audioInfo.buffer,
            soundLocation: audioLocation,
            loudspeakerLocation: information.location,
            innerRoom: self.innerRoom,
            outerRoom: self.outerRoom
        )
        
        self.playAudioFromFloatArray(floatArray: soundPath)
    }
    
}

