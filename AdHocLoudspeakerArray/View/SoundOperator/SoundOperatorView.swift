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
import simd

struct SoundOperatorView: View {
    
    let screen: CGRect = UIScreen.main.bounds
    
    @State var isOpenSideMenu: Bool = false
    
    @State var outerRoomWidth: Float = 10
    @State var outerRoomHeight: Float = 10
    
    let soundImageSize: CGFloat = 50
    @State var soundLocation: CGPoint = CGPoint(x: 25, y: 25)
    @State private var soundLocationBasedNI: CGPoint = CGPoint(x: -5, y: 10)
    
    @ObservedObject var soundOpelatorModel: SoundOperatorModel = SoundOperatorModel()
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.yellow
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text("Sound operator")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .bold()
                        .foregroundColor(Color.white)
                        .onReceive(timer) { _ in
                            self.timerAction()
                        }
                        .navigationBarItems(leading: (
                            Button(action: {
                                self.isOpenSideMenu.toggle()
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .imageScale(.large)
                                Text("Outer room setting")
                                    .bold()
                                    .foregroundColor(Color.white)
                            }))
                    
                    VStack{
                        GeometryReader(content: {geometry in
                            
                            ZStack{
                                Rectangle()
                                    .stroke(Color.white, lineWidth: 3.0)
                                    .frame(width:geometry.size.width, height: geometry.size.height)
                                
                                ArrowShape()
                                    .stroke(Color.orange, lineWidth: 5)
                                    .position(x: geometry.size.width/2, y: geometry.size.height)
                                
                                ArrowShape()
                                    .stroke(Color.orange, lineWidth: 5)
                                    .rotationEffect(Angle(degrees: -90.0))
                                    .frame(width: geometry.size.height, height: 100)
                                
                                
                            }
                            
                            ConvexHullShape(points: self.soundOpelatorModel.innerRoomPoints, outerRoomWidth: self.outerRoomWidth)
                                .stroke(Color.white, lineWidth: 3.0)
                            
                            ForEach(self.soundOpelatorModel.loudspeakerPoints, id: \.self){ point in
                                Image("LoudspeakerMark")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .position(self.movePointToViewCoordinateReference(point: point))
                            }
                            
                            Image("MovingSoundMark")
                                .resizable()
                                .frame(width: self.soundImageSize, height: self.soundImageSize)
                                .position(self.soundLocation)
                                .gesture(DragGesture().onChanged({ value in
                                    
                                    if value.location.x < soundImageSize/2 {
                                        self.soundLocation.x = soundImageSize/2
                                    }else if value.location.x > screen.width - soundImageSize/2 {
                                        self.soundLocation.x = screen.width - soundImageSize/2
                                    }else {
                                        self.soundLocation.x = value.location.x
                                    }
                                    
                                    if value.location.y < soundImageSize/2 {
                                        self.soundLocation.y = soundImageSize/2
                                    }else if value.location.y > screen.width - soundImageSize/2 {
                                        self.soundLocation.y = screen.width - soundImageSize/2
                                    }else {
                                        self.soundLocation.y = value.location.y
                                    }
                                    
                                    self.soundLocationBasedNI =  self.calcSoundLocationBasedOnOperatorPoint(point: self.soundLocation)
                                    
                                    let roundLocation = simd_float3(
                                        x: round(Float(self.soundLocationBasedNI.x) * 100) / 100,
                                        y: 0,
                                        z: round(Float(self.soundLocationBasedNI.y) * 100) / 100
                                    )

//                                    self.soundOpelatorModel.audioStreamer.location = roundLocation
                                    if self.soundOpelatorModel.audioStreamer.location != roundLocation {
                                        self.soundOpelatorModel.audioStreamer.location = roundLocation
                                        self.soundOpelatorModel.sendAudioLocationInfoMessage()
                                        print("enter")
                                    }
                                }))
                            
                        })
                        
                    }.frame(width: screen.width, height: CGFloat((self.outerRoomHeight/self.outerRoomWidth)) * screen.width)
                    
                    Text(self.soundOpelatorModel.testText)
                        .foregroundColor(Color.white)
                        .lineLimit(nil)
                    
                    Text("Number of units: " + String(self.soundOpelatorModel.loudspeakerMCPeerIDs.count))
                        .font(.title2)
                        .foregroundColor(Color.white)
                    
                    Text("Test " + String(self.soundOpelatorModel.testText))
                        .font(.title2)
                        .foregroundColor(Color.white)
                    
                    HStack{
                        
                        Text("sound location: ")
                            .font(.title2)
                            .foregroundColor(Color.white)
                        
                        VStack{
                            Text("x: \(soundLocationBasedNI.x)")
                                .font(.title2)
                                .foregroundColor(Color.white)
                            Text("z: \(soundLocationBasedNI.y)")
                                .font(.title2)
                                .foregroundColor(Color.white)
                        }
                    }
                    
                    
                    HStack{
                        Text("Hosting: ")
                            .font(.title2)
                            .foregroundColor(Color.white)
                        
                        Button(action: {
                            self.soundOpelatorModel.startHosting()
                        }) {
                            Text("Start")
                        }.buttonStyle(RoundedCornersButtonStyle())
                        
                        Button(action: {
                            self.soundOpelatorModel.stopHosting()
                        }) {
                            Text("Stop")
                        }.buttonStyle(RoundedCornersButtonStyle())
                        
                    }
                    
                    HStack{
                        Text("Send: ")
                            .font(.title2)
                            .foregroundColor(Color.white)
                        
                        Button(action: {
                            self.soundOpelatorModel.initAudioBuffer()
                        }) {
                            Text("Audio")
                        }.buttonStyle(RoundedCornersButtonStyle())
                        
                        Button(action: {
                            self.soundOpelatorModel.sendOuterRoomInfoMessage()
                        }) {
                            Text("Outer room")
                        }.buttonStyle(RoundedCornersButtonStyle())
                        Button(action: {
//                            self.soundOpelatorModel.sendLoudspeakerInfoMessage()
                            self.soundOpelatorModel.sendNISessionData()
                            self.soundOpelatorModel.excludeDuplicatePeerIDs()
                        }) {
                            Text("Force update")
                        }.buttonStyle(RoundedCornersButtonStyle())
                    }
                    
                    
                    HStack{
                        
                    }
                }
                
                
                SideMenuView(
                    isOpen: $isOpenSideMenu,
                    outerRoomInfo: $soundOpelatorModel.outerRoom,
                    soWidth: $outerRoomWidth,
                    soHeight: $outerRoomHeight
                )
                .edgesIgnoringSafeArea(.all)
                
            }
        }
    }
    
    
    func timerAction(){
        self.soundOpelatorModel.sendAudioInfoMessage()
//        self.soundOpelatorModel.sendAudioLocationInfoMessage()
    }
    
    private func movePointToViewCoordinateReference(point: simd_float2)->CGPoint{
        
        let originVector: simd_float2 =  simd_float2(Float(screen.width)/2, Float(screen.width))
        let screenLengthRatioPerMeter: Float = Float(screen.width) / self.outerRoomWidth
 
        return CGPoint(
            x: CGFloat(originVector.x + (point.x * screenLengthRatioPerMeter)),
            y: CGFloat(originVector.y - (point.y * screenLengthRatioPerMeter))
            )
    }
    
    func calcSoundLocationBasedOnOperatorPoint(point: CGPoint) -> CGPoint{
        
        let lengthRatioPerPixel = CGFloat(self.outerRoomWidth) / self.screen.width
        let originVector = CGPoint(x: CGFloat(-self.outerRoomWidth / 2), y: CGFloat(self.outerRoomHeight))
        
        return CGPoint(x: originVector.x +  (point.x * lengthRatioPerPixel),
                                    y: originVector.y -  (point.y * lengthRatioPerPixel))
    }
    
}

#Preview {
    SoundOperatorView()
}
