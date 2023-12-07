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
    
    func test(){
        
        let porigon: [simd_float3] = [
            simd_float3(-1, 0, 2),
            simd_float3(-1, 0, 4),
            simd_float3(0, 0, 5),
            simd_float3(1, 0, 5),
            simd_float3(2, 0, 2)
        ]
        
        let i = InnerRoomInfoMessage(locations: porigon)
        let s1 = simd_float3(-2, 0, 1)
        let l1 = simd_float3(-1, 0, 2)
        
        let s2 = simd_float3(5, 0, 5)
        let l2 = simd_float3(1, 0, 5)
        print("Test1: ")
        print(judgeIntersection(soundPosition: s1, loudspeakerPosition: l1, innerRoom: i))
        print(judgeIntersection(soundPosition: s2, loudspeakerPosition: l2, innerRoom: i))
        
    }
    
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
    
    func judgeIntersection(p1: simd_float3, p2: simd_float3, p3: simd_float3, p4: simd_float3)->Bool{
        
        let a: simd_float2 = simd_float2(x: p1.x, y: p1.z)
        let b: simd_float2 = simd_float2(x: p2.x, y: p2.z)
        let c: simd_float2 = simd_float2(x: p3.x, y: p3.z)
        let d: simd_float2 = simd_float2(x: p4.x, y: p4.z)
        
        let cd: simd_float2 = d - c
        let ca: simd_float2 = a - c
        let cb: simd_float2 = b - c
        
        let s: simd_float3 = simd_cross(cd, ca)
        let t: simd_float3 = simd_cross(cd, cb)
        
        if s.z*t.z < 0{
            return true
        }
        
        return false
    }
    
    func judgeIntersection(soundPosition: simd_float3, loudspeakerPosition: simd_float3, innerRoom: InnerRoomInfoMessage)->Bool{
        let points: [simd_float3] = innerRoom.locations
        for i in 0..<points.count {
            print("p3")
            print(points[i])
            print("p4")
            print(points[(i+1)%points.count])
            if judgeIntersection(
                p1: soundPosition,
                p2: loudspeakerPosition,
                p3: points[i],
                p4: points[(i+1)%points.count]
            ) {
                return true
            }
            
        }
        
        return false
    }
    
    func judgeIntersection(soundPosition: simd_float3, loudspeakerPosition: simd_float3, imageInnerRooms: [InnerRoomInfoMessage])->Bool{
        for imageInnerRoom in imageInnerRooms {
            if self.judgeIntersection(soundPosition: soundPosition, loudspeakerPosition: loudspeakerPosition, innerRoom: imageInnerRoom) {
                return true
            }
        }
        return false
    }
    
    func getXAxisSymmetryPoint(point: simd_float3, outerRoom: OuterRoomInfoMessage)->simd_float3{
        return simd_float3(x: point.x, y: point.y, z: -point.z + outerRoom.height)
    }
    
    func getZAxisSymmetryPoint(point: simd_float3, outerRoom: OuterRoomInfoMessage)->simd_float3{
        return simd_float3(x: point.x, y: point.y, z: -point.z)
    }
    
    func getOriginAxisSymmetryPoint(point: simd_float3, outerRoom: OuterRoomInfoMessage)->simd_float3{
        var symPoint: simd_float3
        symPoint = getXAxisSymmetryPoint(point: point, outerRoom: outerRoom)
        symPoint = getZAxisSymmetryPoint(point: symPoint, outerRoom: outerRoom)
        return symPoint
    }
    
    func getSymmetryPoint(point: simd_float3, outerRoom: OuterRoomInfoMessage, reflectivePeturn: String)->simd_float3{
        var symPoint: simd_float3 = point
        switch reflectivePeturn {
        case "x":
            symPoint = self.getXAxisSymmetryPoint(point: symPoint, outerRoom: outerRoom)
            break
        case "z":
            symPoint = self.getZAxisSymmetryPoint(point: symPoint, outerRoom: outerRoom)
            break
        case "o":
            symPoint = self.getOriginAxisSymmetryPoint(point: symPoint, outerRoom: outerRoom)
            break
        default:
            break
        }
        return symPoint
    }
    
    func getSymmetryInnerRoom(innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage, reflectivePattern: String)->InnerRoomInfoMessage{
        
        var symInnerRoom: InnerRoomInfoMessage = innerRoom
        
        switch reflectivePattern {
        case "x":
            for i in 0..<innerRoom.locations.count{
                symInnerRoom.locations[i] = self.getXAxisSymmetryPoint(point: symInnerRoom.locations[i], outerRoom: outerRoom)
            }
            break
        case "z":
            for i in 0..<innerRoom.locations.count{
                symInnerRoom.locations[i] = self.getZAxisSymmetryPoint(point: symInnerRoom.locations[i], outerRoom: outerRoom)
            }
            break
        case "o":
            for i in 0..<innerRoom.locations.count{
                symInnerRoom.locations[i] = self.getXAxisSymmetryPoint(point: symInnerRoom.locations[i], outerRoom: outerRoom)
            }
            break
        default:
            break
        }
        
        return symInnerRoom
    }
    
    func moveInnerRoom(innerRoom: InnerRoomInfoMessage, movedVec: simd_float3)->InnerRoomInfoMessage{
        var movedInnerRoom: InnerRoomInfoMessage = innerRoom
        
        for i in 0 ..< movedInnerRoom.locations.count {
            movedInnerRoom.locations[i] += movedVec
        }
        
        return movedInnerRoom
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
            self.soundPathBuffer[index + delayIndex] += soundBlock*attenuation
            index += 1
        }
    }
    
    func setFirstReflectedPath(soundBuffer: [Float], soundLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage, reflectivePattern: String, movedVec: simd_float3){
        
        var symInnerRoom: InnerRoomInfoMessage =  self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: reflectivePattern)
        var symLoudspeakerLocation: simd_float3 = self.getSymmetryPoint(point: loudspeakerLocation, outerRoom: outerRoom, reflectivePeturn: reflectivePattern)
        
        symInnerRoom = self.moveInnerRoom(innerRoom: symInnerRoom, movedVec: movedVec)
        symLoudspeakerLocation = symLoudspeakerLocation + movedVec
        
        if !judgeIntersection(soundPosition: soundLocation, loudspeakerPosition: symLoudspeakerLocation, imageInnerRooms: [innerRoom, symInnerRoom]) {
            var soundDistance: Float = testDistance(sv: soundLocation, lv: symLoudspeakerLocation)
            soundDistance = soundDistance < 0.2 ? 0.2 : soundDistance
            let delayIndex: Int = self.getDelayIndex(soundDistance: soundDistance)
            let attenuation: Float = self.getAttenuation(soundDistance: soundDistance)
            
            var index = 0
            for soundBlock in soundBuffer {
                self.soundPathBuffer[index + delayIndex] += soundBlock*attenuation*outerRoom.wallCoefficient
                index += 1
            }
        }
    }
    
    //for up down left right
    func setSecondReflectedPath(soundBuffer: [Float], soundLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage, reflectivePattern: String, movedVec: simd_float3){
        
        let firstSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: reflectivePattern),
            movedVec: movedVec/2
        )
        
        let secondSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: innerRoom,
            movedVec: movedVec
        )
        
        let symLoudspeakerLocation: simd_float3  = loudspeakerLocation + movedVec
        
        if !self.judgeIntersection(
            soundPosition: soundLocation,
            loudspeakerPosition: symLoudspeakerLocation,
            imageInnerRooms: [innerRoom, firstSymInnerRoom, secondSymInnerRoom]
        ) {
            
            var soundDistance: Float = testDistance(sv: soundLocation, lv: symLoudspeakerLocation)
            soundDistance = soundDistance < 0.2 ? 0.2 : soundDistance
            let delayIndex: Int = self.getDelayIndex(soundDistance: soundDistance)
            let attenuation: Float = self.getAttenuation(soundDistance: soundDistance)
            
            var index = 0
            for soundBlock in soundBuffer {
                self.soundPathBuffer[index + delayIndex] += soundBlock*attenuation*pow(outerRoom.wallCoefficient, 2)
                index += 1
            }
            
        }
    }
    
    // for diagonal
    func setSecondReflectedPath(soundBuffer: [Float], soundLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage, movedVec: simd_float3){
        
        let firstXSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: "x"),
            movedVec: simd_float3(0, 0, movedVec.z)
        )
        
        let firstZSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: "z"),
            movedVec: simd_float3(movedVec.x, 0, 0)
        )
        
        let secondSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: "o"),
            movedVec: movedVec
        )
        
        let symLoudspeakerLocation: simd_float3  = loudspeakerLocation + movedVec
        
        if !self.judgeIntersection(
            soundPosition: soundLocation,
            loudspeakerPosition: symLoudspeakerLocation,
            imageInnerRooms: [innerRoom, firstXSymInnerRoom, firstZSymInnerRoom, secondSymInnerRoom]
        ) {
            
            var soundDistance: Float = testDistance(sv: soundLocation, lv: symLoudspeakerLocation)
            soundDistance = soundDistance < 0.2 ? 0.2 : soundDistance
            let delayIndex: Int = self.getDelayIndex(soundDistance: soundDistance)
            let attenuation: Float = self.getAttenuation(soundDistance: soundDistance)
            
            var index = 0
            for soundBlock in soundBuffer {
                self.soundPathBuffer[index + delayIndex] += soundBlock*attenuation*pow(outerRoom.wallCoefficient, 2)
                index += 1
            }
            
        }
    }
    
    func setFirstReflectedPaths(soundBuffer: [Float], soundLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage){
        
        //Up
        self.setFirstReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "x",
            movedVec: simd_float3(0, 0, outerRoom.height)
        )
        
        //Down
        self.setFirstReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "x",
            movedVec: simd_float3(0, 0, -outerRoom.height)
        )
        
        //Left
        self.setFirstReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "z",
            movedVec: simd_float3(-outerRoom.width, 0, 0)
        )
        
        //Right
        self.setFirstReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "z",
            movedVec: simd_float3(outerRoom.width, 0, 0)
        )
    }
    
    func setSecondReflectedPaths(soundBuffer: [Float], soundLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage){
        
        // Up
        self.setSecondReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "x",
            movedVec: simd_float3(0, 0, outerRoom.height*2)
        )
        
        // Down
        self.setSecondReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "x",
            movedVec: simd_float3(0, 0, -outerRoom.height*2)
        )
        
        // Left
        self.setSecondReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "z",
            movedVec: simd_float3(-outerRoom.width*2, 0, 0)
        )
        
        // Right
        self.setSecondReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "z",
            movedVec: simd_float3(outerRoom.width*2, 0, 0)
        )
        
        // Upper right diagonal
        self.setSecondReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            movedVec: simd_float3(outerRoom.width, 0, outerRoom.height)
        )
        
        // Lower right diagonal
        self.setSecondReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            movedVec: simd_float3(outerRoom.width, 0, -outerRoom.height)
        )
        
        // Upper left diagonal
        self.setSecondReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            movedVec: simd_float3(-outerRoom.width, 0, outerRoom.height)
        )
        
        // Lower left diagonal
        self.setSecondReflectedPath(
            soundBuffer: soundBuffer,
            soundLocation: soundLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            movedVec: simd_float3(-outerRoom.width, 0, -outerRoom.height)
        )
        
    }
    
    func getPathFromBuffer()->[Float]{
        let soundPath: [Float] = Array(self.soundPathBuffer[0 ..< self.soundBufferSize])
        self.soundPathBuffer.removeFirst(self.soundBufferSize)
        self.soundPathBuffer = self.soundPathBuffer + Array(repeating: 0, count: self.soundBufferSize)
        return soundPath
    }
    
    func calcSoundPath(
        soundFloatArray: [Float],
        soundLocation: simd_float3,
        loudspeakerLocation: simd_float3,
        innerRoom: InnerRoomInfoMessage,
        outerRoom: OuterRoomInfoMessage
    )->[Float]{
        self.setDirectPath(soundBuffer: soundFloatArray, soundLocation: soundLocation, loudspeakerLocation: loudspeakerLocation)
        self.setFirstReflectedPaths(soundBuffer: soundFloatArray, soundLocation: soundLocation, loudspeakerLocation: loudspeakerLocation, innerRoom: innerRoom, outerRoom: outerRoom)
        self.setSecondReflectedPaths(soundBuffer: soundFloatArray, soundLocation: soundLocation, loudspeakerLocation: loudspeakerLocation, innerRoom: innerRoom, outerRoom: outerRoom)
        return getPathFromBuffer()
    }
}
