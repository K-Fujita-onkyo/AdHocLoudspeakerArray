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

struct TopPageView: View {
    
    @State private var showLoudspeakerView: Bool = false
    @State private var showSoundOpelatorView: Bool = false
    
    // Position button
    private  var positionList: [Position] = [
        Position(id: 0, name: "Loudspeaker", imageName: "LoudspeakerMark"),
        Position(id: 1, name: "Sound operator", imageName: "SoundOperatorMark"),
    ]
    
    // MARK: -
    var body: some View {
        VStack {
            VStack{
                
                Text("Please select your position.")
                    .font(.title2)
                    .foregroundColor(Color.white)
                
                Button(action: {
                    self.showLoudspeakerView.toggle()
                }) {
                    PositionView(position: positionList[0])
                }.sheet(isPresented: self.$showLoudspeakerView) {
                    LoudspeakerView()
                }.buttonStyle(RoundedCornersButtonStyle())
                
                Button(action: {
                    self.showSoundOpelatorView.toggle()
                }) {
                    PositionView(position: positionList[1])
                }.sheet(isPresented: self.$showSoundOpelatorView) {
                    SoundOperatorView()
                }.buttonStyle(RoundedCornersButtonStyle())
                
            }
        }
        .padding()
    }
}

#Preview {
    TopPageView()
}
