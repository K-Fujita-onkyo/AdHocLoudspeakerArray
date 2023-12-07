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
    @Published var test: String = "test"
    @Published var isConnected: String = "Not connected."
    @Published var information: LoudspeakerInfoMessage = LoudspeakerInfoMessage(isConvexHull: false, location: simd_float3(x: 0, y: 0, z: 0))
    
    var innerRoom: InnerRoomInfoMessage = InnerRoomInfoMessage(locations: [])
    var outerRoom: OuterRoomInfoMessage = OuterRoomInfoMessage(width: 10, height: 10, wallCoefficient: 0.05)
    let soundPathCalculator: SoundPathModel = SoundPathModel()
    
    let audioEngine: AVAudioEngine = AVAudioEngine()
    let audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!
    
    override init(){
        super.init()
        self.setupAudioPlayer()
        self.playAudio()
    }
    
    // MARK: - NISessionDelegate Methods
    
    // Session to to detect movement of other devices
    // Notifies me when the session updates nearby objects.
    override func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
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
            self.sendData(data: self.myDiscoveryTokenData, mcPeerIDs: session.connectedPeers)
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
        }
        
        if let audioInfo = self.convertDataToInstance(type: AudioInfoMessage.self, data: data){
            print(audioInfo.location)
            let soundPath = self.soundPathCalculator.calcSoundPath(
                soundFloatArray: audioInfo.buffer,
                soundLocation: audioInfo.location,
                loudspeakerLocation: information.location,
                innerRoom: self.innerRoom,
                outerRoom: self.outerRoom
            )
            self.playAudioFromFloatArray(floatArray: soundPath)
        }
        
        if let outerRoomInfo = self.convertDataToInstance(type: OuterRoomInfoMessage.self, data: data){
            self.outerRoom = outerRoomInfo
        }
        
        if let innerRoomInfo = self.convertDataToInstance(type: InnerRoomInfoMessage.self, data: data){
            self.innerRoom = innerRoomInfo
        }
        
        self.startNISession(niDiscoveryTokenData: data)
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
    
}

