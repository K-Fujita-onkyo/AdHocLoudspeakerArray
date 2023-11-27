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
    // MARK: - Test Instances
    @Published var test: String = "test"
    @Published var loudspeakerInfoDict: LoudspeakerInformationsDictionary = LoudspeakerInformationsDictionary()
    var innerRoom: ConvexHullInfoModel = ConvexHullInfoModel()
    
    override init() {
        super.init()
    }
    
    func updateLoudspeakerLocation(nearbyObject: NINearbyObject){
        
        let niDiscoveryToken: NIDiscoveryToken = nearbyObject.discoveryToken
        let distance: Float! = nearbyObject.distance
        var direction: simd_float3! = nearbyObject.direction
        
        if  distance == nil || direction == nil {
            print("Debug(soModel): Can't measure the location of \(niDiscoveryToken)")
            return
        }
        
        // FIXME: - This is for simulator values. Please deleted in a real test.
        direction = simd_float3(x: direction.x * 10, y: direction.z * 10, z: direction.y * 10)
        
        self.loudspeakerInfoDict.updateValue(
            key: niDiscoveryToken,
            isConvexHull: false,
            unitVector: direction,
            distance: distance
        )
        
    }
    
    // MARK: - NISessionDelegate Methods
    
    // Session to to detect movement of other devices
    // Notifies me when the session updates nearby objects.
    override func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        
        self.innerRoom.reset()
        self.loudspeakerInfoDict.resetIsConvexHull()
        
        for nearbyObject in nearbyObjects {
            self.updateLoudspeakerLocation(nearbyObject: nearbyObject)
        }
        
        self.innerRoom.appendPointsByLIDict(loudspeakerInfoDict: self.loudspeakerInfoDict)
        self.innerRoom.calculateConvexHull()
        
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
    
    // MARK: - MCSessionDelegate Methods
    
    // Session to change my state
    // Called when the state of a nearby peer changes.
    // State: connected, notConnected, and connecting
    override func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case .connected:
            print("Connected")
            self.sendData(data: self.myDiscoveryTokenData, mcPeerIDs: session.connectedPeers)
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

        if let niDiscoveryToken:NIDiscoveryToken = self.startNISession(niDiscoveryTokenData: data) {
            self.loudspeakerInfoDict.updateValue(key: niDiscoveryToken, loudspeakerInfoModel: LoudspeakerInfoModel(mcPeerID: peerID))
        }
        
    }
}
