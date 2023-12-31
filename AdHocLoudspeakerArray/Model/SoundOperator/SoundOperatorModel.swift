///
///
///Project name: AdHocLoudspeakerArray
/// Class name: SoundOperatorModel
/// Creator: Kazuki Fujita
/// Update: 2023/11/27 (Mon)
///
/// ---Explanation---
/// Sound operator model
///
///

import Foundation
import NearbyInteraction
import MultipeerConnectivity

class SoundOperatorModel: AdHocModel, ObservableObject {
    
    @Published var loudspeakerPoints: [simd_float2] = []
    @Published var innerRoomPoints: [simd_float2] = []
    @Published var testText: String = ""
    
    // MARK: - Test Instances
    @Published var loudspeakerInfoDict: LoudspeakerInformationsDictionary = LoudspeakerInformationsDictionary()
    @Published var loudspeakerMCPeerIDs: [MCPeerID] = []
    var innerRoom: ConvexHullInfoModel = ConvexHullInfoModel()
    @Published var outerRoom: OuterRoomInfoModel = OuterRoomInfoModel()
    var audioStreamer: AudioStreamerModel = AudioStreamerModel()
    @Published var audioLocation = simd_float3(x: 0, y: 0, z: 0)
    
    var niSessionDict: [MCPeerID: NISession]  = [:]
    var niTokenMapping: [NIDiscoveryToken: MCPeerID] = [:]
    var niSession1: NISession = NISession()
    var niSession2: NISession = NISession()
    var niSession3: NISession = NISession()
    var niSession4: NISession = NISession()
    var niSession5: NISession = NISession()
    var niSession6: NISession = NISession()
    var niSession7: NISession = NISession()
    var peerIDNumber: [MCPeerID: Int] = [:]
    var myniSessionTokens: [NIDiscoveryToken] = []
    
    override init() {
        super.init()
        self.setupNISession()
    }
    

    func setupNISession(){
        
        self.niSession1.delegate = self
        self.niSession2.delegate = self
        self.niSession3.delegate = self
        self.niSession4.delegate = self
        self.niSession5.delegate = self
        self.niSession6.delegate = self
        self.niSession7.delegate = self
        
        guard let token1 = self.niSession1.discoveryToken else {
            return
        }
        guard let token2 = self.niSession2.discoveryToken else {
            return
        }
        guard let token3 = self.niSession3.discoveryToken else {
            return
        }
        guard let token4 = self.niSession4.discoveryToken else {
            return
        }
        guard let token5 = self.niSession5.discoveryToken else {
            return
        }
        guard let token6 = self.niSession6.discoveryToken else {
            return
        }
        guard let token7 = self.niSession7.discoveryToken else {
            return
        }
        
        self.myniSessionTokens =
        [token1,
         token2,
         token3,
         token4,
         token5,
         token6,
         token7
        ]
    }
    
    func sendNISessionData(){
        
        var tokenNumber = 1
        for lsMCPeerID in loudspeakerMCPeerIDs {
            let niSessionTokenData = try! NSKeyedArchiver.archivedData(withRootObject: myniSessionTokens[tokenNumber], requiringSecureCoding: true)
            sendData(data: niSessionTokenData, mcPeerID: lsMCPeerID)
            peerIDNumber.updateValue(tokenNumber , forKey: lsMCPeerID)
            tokenNumber+=1
        }
    }
    
    func startNISession(niDiscoveryTokenData: Data, mcPeerID: MCPeerID) -> NIDiscoveryToken!{
        guard let niDiscoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: niDiscoveryTokenData)
        else {
            return nil
        }
        
        let config = NINearbyPeerConfiguration(peerToken: niDiscoveryToken)
        
        if peerIDNumber[mcPeerID]==1 {
            self.niSession1.run(config)
        }
        if peerIDNumber[mcPeerID]==2 {
            self.niSession2.run(config)
        }
        if peerIDNumber[mcPeerID]==3 {
            self.niSession3.run(config)
        }
        if peerIDNumber[mcPeerID]==4 {
            self.niSession4.run(config)
        }
        if peerIDNumber[mcPeerID]==5 {
            self.niSession5.run(config)
        }
        if peerIDNumber[mcPeerID]==6 {
            self.niSession6.run(config)
        }
        if peerIDNumber[mcPeerID]==7 {
            self.niSession7.run(config)
        }
        
        return niDiscoveryToken
    }
    
    func updateLoudspeakerLocation(nearbyObject: NINearbyObject){
        
        let niDiscoveryToken: NIDiscoveryToken = nearbyObject.discoveryToken
        let distance: Float! = nearbyObject.distance
        var direction: simd_float3! = nearbyObject.direction
        
        if  distance == nil || direction == nil {
            testText = "Debug(soModel): Can't measure the location of \(niDiscoveryToken)"
            return
        }
        
        direction = simd_float3(x: direction.x , y: direction.y  , z: -direction.z)
        
        self.loudspeakerInfoDict.updateValue(
            key: niDiscoveryToken,
            isConvexHull: false,
            unitVector: direction,
            distance: distance
        )
        
    }
    
    @objc func sendAudioInfoMessage(){
        
        if self.loudspeakerMCPeerIDs.isEmpty {
            return
        }
        
        if let audioInfoMessage: AudioInfoMessage = self.audioStreamer.getAudioInfoMessage(){
            if let data: Data  = self.convertInstanceToData(instance: audioInfoMessage){
                self.sendData(data: data, mcPeerIDs: loudspeakerMCPeerIDs)
            }
        }
    }
    
    @objc func sendAudioLocationInfoMessage(){
       
        if self.loudspeakerMCPeerIDs.isEmpty {
            return
        }
        
        if let audioLocationInfoMessage: AudioLocationInfoMessage = self.audioStreamer.getAudioLocationInfoMessage(){
            if let data: Data  = self.convertInstanceToData(instance: audioLocationInfoMessage){
                self.sendData(data: data, mcPeerIDs: loudspeakerMCPeerIDs)
            }
        }
    }
    
    func sendOuterRoomInfoMessage(){
        let outerRoomInfoMessage: OuterRoomInfoMessage = self.outerRoom.getOuterRoomInfoMessage()
        if let data: Data = self.convertInstanceToData(instance: outerRoomInfoMessage) {
            self.sendData(data: data, mcPeerIDs: loudspeakerMCPeerIDs)
        }
    }
    
    func sendLoudspeakerInfoMessage(){
        
        for (_, loudspeakerInfo) in self.loudspeakerInfoDict.dictionary {
            
            let message: LoudspeakerInfoMessage!
            let mcPeerID: MCPeerID!
            let data: Data!
            
            message = loudspeakerInfo.outputMessage()
            mcPeerID = loudspeakerInfo.mcPeerID
            data = convertInstanceToData(instance: message)
            
            if message == nil || mcPeerID  == nil || data == nil{
                break
            }
            
            self.sendData(data: data, mcPeerID: mcPeerID)
        }
    }
    
    func sendInnerRoomInfoMessage(){
        let innerRoomMessage: InnerRoomInfoMessage = self.innerRoom.getInnerRoomInfoMessage()
        if let data: Data = self.convertInstanceToData(instance: innerRoomMessage) {
            self.sendData(data: data, mcPeerIDs: self.loudspeakerMCPeerIDs)
        }
    }
    
    // MARK: - NISessionDelegate Methods
    
    // Session to to detect movement of other devices
    // Notifies me when the session updates nearby objects.
    override func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        
        self.innerRoom.reset()
        self.loudspeakerInfoDict.resetIsConvexHull()
        self.testText = String(nearbyObjects.count)
        
        for nearbyObject in nearbyObjects {
            self.updateLoudspeakerLocation(nearbyObject: nearbyObject)
        }
        
        self.loudspeakerPoints = self.loudspeakerInfoDict.getAllLoudspeakerLocation()
        self.innerRoom.appendPointsByLIDict(loudspeakerInfoDict: self.loudspeakerInfoDict)
        self.innerRoom.calculateConvexHull()
        self.innerRoomPoints = self.innerRoom.getConvPoints()
//        self.sendInnerRoomInfoMessage()
        
        
        for (niDiscoveryToken, _) in self.innerRoom.convexHull.array {
            self.loudspeakerInfoDict.dictionary[niDiscoveryToken!]?.isConvexHull = true
            
        }
        
        
        for (_, loudspeakerInfo) in self.loudspeakerInfoDict.dictionary {
            
            let message: LoudspeakerInfoMessage!
            let mcPeerID: MCPeerID!
            let data: Data!
            
            message = loudspeakerInfo.outputMessage()
            mcPeerID = loudspeakerInfo.mcPeerID
            data = convertInstanceToData(instance: message)
            
            if message == nil || mcPeerID  == nil || data == nil{
                break
            }
            
            self.sendData(data: data, mcPeerID: mcPeerID)
        }
    }
    
    
    func sessionSuspensionEnd(_ session: NISession) {
        session.run(session.configuration!)
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        self.testText = error.localizedDescription
    }
    
    func excludeDuplicatePeerIDs(){
        self.loudspeakerMCPeerIDs = Array(Set(self.loudspeakerMCPeerIDs))
    }
    
    // MARK: - MCSessionDelegate Methods
    
    // Session to change my state
    // Called when the state of a nearby peer changes.
    // State: connected, notConnected, and connecting
    override func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case .connected:
            print("Connected")
            self.loudspeakerMCPeerIDs.append(peerID)
            self.excludeDuplicatePeerIDs()
        case .connecting:
            print("Connecting")
            
        case .notConnected:
            print("Not connected")
            
        default:
            print("Other")
        }
    }
    
    // Session to get data
    // Indicates that an NSData object has been received from a nearby peer.
    override func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        if let niDiscoveryToken:NIDiscoveryToken = self.startNISession(niDiscoveryTokenData: data, mcPeerID: peerID) {
            self.loudspeakerInfoDict.updateValue(key: niDiscoveryToken, loudspeakerInfoModel: LoudspeakerInfoModel(mcPeerID: peerID))
            self.sendOuterRoomInfoMessage()
        }else{
        }
        
    }
    
    func initAudioBuffer(){
        self.audioStreamer.assignAudioToBuffer(audioFloatArray: self.audioStreamer.audioFloatArray)
    }
}
