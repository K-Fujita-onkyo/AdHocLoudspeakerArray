//
//  LoudspeakersDictionary.swift
//  AdHocLoudspeakerArray
//
//  Created by 藤田一旗 on 2023/11/24.
//

import Foundation
import NearbyInteraction
import MultipeerConnectivity

class LoudspeakerInformationsDictionary: NSObject {
    
    var dictionary: [NIDiscoveryToken: LoudspeakerInfoModel]
    
    override init() {
        self.dictionary = [:]
        super.init()
    }
    
    func updateValue(key: NIDiscoveryToken, loudspeakerInfoModel: LoudspeakerInfoModel){
        self.dictionary.updateValue(loudspeakerInfoModel, forKey: key)
    }
    
    func updateValue(key: NIDiscoveryToken, loudspeakerInfoMessage: LoudspeakerInfoMessage){
       
        if let loudspeakerInfo: LoudspeakerInfoModel = self.dictionary[key] {
            
            loudspeakerInfo.update(loudspeakerInfoMessage: loudspeakerInfoMessage)
            self.dictionary.updateValue(loudspeakerInfo, forKey: key)
            
        }else{
            print("Debug(lsDict): Can't imput the data.")
        }
    }
    
    func updateValue(key: NIDiscoveryToken, isConvexHull: Bool, x: Float, y: Float, z: Float){
       
        if let loudspeakerInfo: LoudspeakerInfoModel = self.dictionary[key] {
            
            loudspeakerInfo.update(isConvexHull: isConvexHull, x: x, y: y, z: z)
            self.dictionary.updateValue(loudspeakerInfo, forKey: key)
            
        }else{
            print("Debug(lsDict): Can't imput the data.")
        }
    }
    
    func updateValue(key: NIDiscoveryToken, isConvexHull: Bool, unitVector: simd_float3, distance: Float){
        
        if let loudspeakerInfo: LoudspeakerInfoModel = self.dictionary[key] {
            
            loudspeakerInfo.update(isConvexHull: isConvexHull, unitVector: unitVector, distance: distance)
            self.dictionary.updateValue(loudspeakerInfo, forKey: key)
            
        }else{
            print("Debug(lsDict): Can't imput the data.")
        }
    }
    
    func getValue(key: NIDiscoveryToken)->LoudspeakerInfoModel? {
        return self.dictionary[key]
    }
    
    func getLoudspeakerInfoMessage(key: NIDiscoveryToken)->LoudspeakerInfoMessage?{
        return self.dictionary[key]?.outputMessage()
    }
    
    func getMCPeerID(key: NIDiscoveryToken)->MCPeerID? {
        return self.dictionary[key]?.mcPeerID
    }
}
