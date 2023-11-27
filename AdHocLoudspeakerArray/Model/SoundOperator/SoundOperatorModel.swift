///
///
///Project name: AdHocLoudspeakerArray
/// Class name: SoundOperatorModel
/// Creator: Kazuki Fujita
/// Update: 2023/11/24 (Fri)
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
    
    override init() {
        super.init()
    }
    
    func updateLoudspeakerLocation(nearbyObject: NINearbyObject){
        
        let distance: Float! = nearbyObject.distance
        let direction: simd_float3! = nearbyObject.direction
        
        if  distance == nil || direction == nil {
            print("Debug: No distance and direction in \(nearbyObject.discoveryToken)")
            return
        }
        
        
        
    }
    
    // MARK: - NISessionDelegate Methods
    
    // Session to to detect movement of other devices
    // Notifies me when the session updates nearby objects.
    override func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        
        for nearbyObject in nearbyObjects {
            
            let niDiscoveryToken: NIDiscoveryToken = nearbyObject.discoveryToken
            let distance: Float! = nearbyObject.distance
            let direction: simd_float3! = nearbyObject.direction
            
            // If these measurement fails normally
            if distance == nil || direction == nil{
                print("Debug(soModel): Can't measure the location of \(niDiscoveryToken)")
                break
            }
            
            // DEBUG: - print("Debug(soModel): niDiscoveryModel->\(niDiscoveryToken), distance->\(String(describing: distance)), direction->\(String(describing: direction))")
            
            self.loudspeakerInfoDict.updateValue(
                key: niDiscoveryToken,
                isConvexHull: false,
                unitVector: direction,
                distance: distance
            )
            
            let message: LoudspeakerInfoMessage!
            let mcPeerID: MCPeerID!
            let data: Data!
            
            message = self.loudspeakerInfoDict.getLoudspeakerInfoMessage(key: niDiscoveryToken)
            mcPeerID = self.loudspeakerInfoDict.getMCPeerID(key: niDiscoveryToken)
            data = self.convertInstanceToData(instance: message)
            
            if message == nil || mcPeerID  == nil || data == nil{
                break
            }
            print("Debug(soModel): Prepare to send the message.")
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
