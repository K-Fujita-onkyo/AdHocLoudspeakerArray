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
        Text(loudspeakerModel.test)
        Text(String(loudspeakerModel.information.isConvexHull))
        Text("x: " + String(loudspeakerModel.information.location.x))
        Text("y: " + String(loudspeakerModel.information.location.y))
        Text("z: " + String(loudspeakerModel.information.location.z))
        Button(action: {
            self.loudspeakerModel.startBrowsing()
        }) {
            Text("Start Browsing")
        }.buttonStyle(RoundedCornersButtonStyle())
        
        Button(action: {
            self.loudspeakerModel.stopBrowsing()
        }) {
            Text("Stop Browsing")
        }.buttonStyle(RoundedCornersButtonStyle())
        
    }
    
}

#Preview {
    LoudspeakerView()
}
