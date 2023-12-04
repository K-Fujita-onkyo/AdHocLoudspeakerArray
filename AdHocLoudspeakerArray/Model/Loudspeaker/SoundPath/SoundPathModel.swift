///
///
///Project name: AdHocLoudspeakerArray
/// Class name: SoundPathModel
/// Creator: Kazuki Fujita
/// Update: 2023/11/23 (Thu)
///
/// ---Explanation---
/// SoundPathModel
///

import Foundation
import simd

class SoundPathModel: NSObject {
    
    let soundBufferSize: Int = 1024
    let soundSpeed: Float = 340.5  // m/s
    let samlingRate: Int = 44100 // n/s
    let referenceDistance: Float = 1 //m
    var soundPathBuffer: [Float] = Array(repeating: 0, count: 44100)
    
    func getDelaySec(soundDistance: Float)->Float{
        return soundDistance / self.soundSpeed
    }
    
    func getDelayIndex(soundDistance: Float)->Int{
        let delaySec: Float = self.getDelaySec(soundDistance: soundDistance)
        return Int( Float(self.samlingRate) * delaySec)
    }
    
    // Inverse Square Raw
    func getAttenuation(soundDistance: Float) -> Float{
            return pow(self.referenceDistance, 2) / pow(soundDistance, 2)
    }
    
    func testDistance(sv: simd_float3, lv: simd_float3)->Float {
        let sv2 = simd_float2(sv.x, sv.z)
        let lv2 = simd_float2(lv.x, lv.z)
        
        return distance(sv2, lv2)
    }
    
    func setDirectPath(soundBuffer: [Float], soundLocation: simd_float3, loudspeakerLocation: simd_float3){
        
        //var soundDistance: Float = distance(soundLocation, loudspeakerLocation)
        var soundDistance: Float = testDistance(sv: soundLocation, lv: loudspeakerLocation)
        soundDistance = soundDistance < 0.2 ? 0.2 : soundDistance
        print(soundDistance)
        let delayIndex: Int = self.getDelayIndex(soundDistance: soundDistance)
        let attenuation: Float = self.getAttenuation(soundDistance: soundDistance)
        
        var index = 0
        for soundBlock in soundBuffer {
            self.soundPathBuffer[index + delayIndex] = soundBlock*attenuation
            index += 1
        }
    }
    
    func getPathFromBuffer()->[Float]{
        let soundPath: [Float] = Array(self.soundPathBuffer[0 ..< self.soundBufferSize])
        self.soundPathBuffer.removeFirst(self.soundBufferSize)
        self.soundPathBuffer = self.soundPathBuffer + Array(repeating: 0, count: self.soundBufferSize)
        return soundPath
    }
    
    func calcSoundPath(soundFloatArray: [Float], soundLocation: simd_float3, loudspeakerLocation: simd_float3)->[Float]{
        self.setDirectPath(soundBuffer: soundFloatArray, soundLocation: soundLocation, loudspeakerLocation: loudspeakerLocation)
        return getPathFromBuffer()
    }}
