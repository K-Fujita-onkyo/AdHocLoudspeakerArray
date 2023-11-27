///
///
///Project name: AdHocLoudspeakerArray
/// Class name: SoundOperatorView
/// Creator: Kazuki Fujita
/// Update: 2023/11/27 (Mon)
///
/// ---Explanation---
/// Sound operator view
///
///

import SwiftUI

struct SoundOperatorView: View {
    @State var soundOpelatorModel: SoundOperatorModel = SoundOperatorModel()
    var body: some View {
        Text("Sound operator")
        Text(soundOpelatorModel.test)
        Button(action: {
            self.soundOpelatorModel.startHosting()
        }) {
            Text("Start Hosting")
        }.buttonStyle(RoundedCornersButtonStyle())
        
        Button(action: {
            self.soundOpelatorModel.stopHosting()
        }) {
            Text("Stop Hosting")
        }.buttonStyle(RoundedCornersButtonStyle())
    }
    
}

#Preview {
    SoundOperatorView()
}
