///
///
///Project name: AdHocLoudspeakerArray
/// Class name: RoundedCornersButtonStyle
/// Creator: Kazuki Fujita
/// Update: 2023/11/24 (Fri)
///
/// ---Explanation---
/// 
///
///

import Foundation
import SwiftUI

struct RoundedCornersButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(Color.white)
            .background(configuration.isPressed ? Color.red : Color.orange)
            .cornerRadius(12.0)
        }
}
