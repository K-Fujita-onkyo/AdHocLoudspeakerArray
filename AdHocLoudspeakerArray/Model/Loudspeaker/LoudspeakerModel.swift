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
import NearbyInteraction
import MultipeerConnectivity

class LoudspeakerModel: AdHocModel, ObservableObject {
    @Published var test: String = "test"
    @Published var isConnected: String = "Not connected."
    @Published var information: LoudspeakerInfoMessage = LoudspeakerInfoMessage(isConvexHull: false, location: simd_float3(x: 0, y: 0, z: 0))
    
    override init(){
        super.init()
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
        
        self.startNISession(niDiscoveryTokenData: data)
    }
}
