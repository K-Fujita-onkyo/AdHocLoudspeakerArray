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
        
        ZStack {
            
            if loudspeakerModel.information.isConvexHull {
                Color.green
                    .edgesIgnoringSafeArea(.all)
            }else{
                Color.gray
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack{
                Text("Loudspeaker")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .bold()
                    .foregroundColor(Color.white)
                
                Text("P2P: " + loudspeakerModel.isConnected)
                    .font(.title2)
                    .foregroundColor(Color.white)
                
                Text(String(loudspeakerModel.information.isConvexHull))
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("x: " + String(loudspeakerModel.information.location.x))
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("y: " + String(loudspeakerModel.information.location.y))
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("z: " + String(loudspeakerModel.information.location.z))
                    .font(.title2)
                    .foregroundColor(Color.white)
                
                HStack {
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
                
                Button(action: {
                    self.loudspeakerModel.playAudio()
                }) {
                    Text("Play Audio")
                }.buttonStyle(RoundedCornersButtonStyle())
                
            }
        }
    }
    
}

#Preview {
    LoudspeakerView()
}
