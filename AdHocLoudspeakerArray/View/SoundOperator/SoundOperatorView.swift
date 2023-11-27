//
//  SwiftUIView.swift
//  AdHocLoudspeakerArray
//
//  Created by 藤田一旗 on 2023/11/24.
//

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
