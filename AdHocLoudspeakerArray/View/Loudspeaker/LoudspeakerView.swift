///
///
///Project name: AdHocLoudspeakerArray
/// Class name: TopPageView
/// Creator: Kazuki Fujita
/// Update: 2023/11/24 (Fri)
///
/// ---Explanation---
///
///
///

import SwiftUI

struct LoudspeakerView: View {
    
    @State private var isPresented: Bool = false
    @ObservedObject var loudspeakerModel: LoudspeakerModel  = LoudspeakerModel()
    
    var body: some View {
        Text("Loudspeaker")
    }
}

#Preview {
    LoudspeakerView()
}
