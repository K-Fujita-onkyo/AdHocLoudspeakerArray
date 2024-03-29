///
///
///Project name: AdHocLoudspeakerArray
/// Class name: AudioStreamerModel
/// Creator: Kazuki Fujita
/// Update: 2023/11/23 (Thu)
///
/// ---Explanation---
/// Audio Streamer Model
///
///

import Foundation
import AVFoundation

class AudioStreamerModel: NSObject {
    
    let samplingRate: Int = 44100
    let bufferSize: Int = 1024
    var audioFloatArray: [Float] = []
    var audioBufferQueue: QueueModel<[Float]> = QueueModel(array: [])
    var bufferIndex: Int = 0
    var location: simd_float3 = simd_float3(x: -5, y: 0, z: 10)
    
    override init(){
        super.init()
        if let audioURL = Bundle.main.url(forResource: "Drums", withExtension: "wav") {
            self.audioFloatArray = self.audioToFloatArray(audioURL: audioURL)!
        }
    }
    
    func getAudioInfoMessage()->AudioInfoMessage? {
        
        let audioBuffer: [Float]! = self.audioBufferQueue.dequeue()
        
        if audioBuffer == nil {
            return nil
        }
    
        return  AudioInfoMessage(location: self.location, buffer: audioBuffer)
        
    }
    
    func audioToFloatArray(audioURL: URL) -> [Float]? {
        
        do {
            // Read an audio file as AVAudioFile
            let audioFile = try AVAudioFile(forReading: audioURL)
            
           // Get a format of audioFile
            guard let format = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: audioFile.fileFormat.sampleRate,
                channels: audioFile.fileFormat.channelCount,
                interleaved: false
            ) else {
                print("Cannot create AVAudioFormat")
                return nil
            }
            
            // Read PCM data
            guard let audioBuffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                print("Cannot create AVAudioPCMBuffer")
                return nil
            }
            
            try audioFile.read(into: audioBuffer)
            
            // Convert PCM buffer to Float array
            let floatArray = Array(
                UnsafeBufferPointer(
                    start: audioBuffer.floatChannelData?[0],
                    count:Int(audioBuffer.frameLength)
                )
            )
            
            return floatArray
            
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func assignAudioToBuffer(audioFloatArray: [Float]) {
        
        let size: Int = audioFloatArray.count
        var index: Int = 0
        
        while index < size {
            
            var audioBuffer = Array(audioFloatArray[index..<min(index + self.bufferSize, size)])
            
            //If sub array size is smaller than 1024
            while audioBuffer.count < self.bufferSize {
                audioBuffer.append(0.0)
            }
            
            index += self.bufferSize
            
            self.audioBufferQueue.enqueue(element: audioBuffer)
        }
    }
    
}
