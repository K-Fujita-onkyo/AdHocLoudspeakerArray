//
//  SoundInfoMessage.swift
//  AdHocLoudspeakerArray
//
//  Created by 藤田一旗 on 2023/11/24.
//

import Foundation
import simd

struct AudioInfoMessage: Codable {
    var location: simd_float3
    var buffer: [Float]
}
