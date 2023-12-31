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
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
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
                    .onReceive(timer){_ in
                        self.timerAction()
                    }
                
                Text("P2P: " + loudspeakerModel.isConnected)
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("NISession: " + loudspeakerModel.isStartNISession)
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("Text: " + loudspeakerModel.testText)
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
                
//                Text("Test: " + loudspeakerModel.testText)
//                    .font(.title2)
//                    .foregroundColor(Color.white)
                
                Text("direction: " + loudspeakerModel.testText2)
                    .foregroundColor(Color.white)
                    .lineLimit(nil)
                Text("distance: " + loudspeakerModel.testText3)
                    .foregroundColor(Color.white)
                    .lineLimit(nil)
                
                Button(action: {
                    self.loudspeakerModel.update()
                }) {
                    Text("tests")
                }.buttonStyle(RoundedCornersButtonStyle())
                
            }
        }
    }
    
    func timerAction(){
        self.loudspeakerModel.spatializeSoundInRealTime()
    }
    
}



#Preview {
    LoudspeakerView()
}
