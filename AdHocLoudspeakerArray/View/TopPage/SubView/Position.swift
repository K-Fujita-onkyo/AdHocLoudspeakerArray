import Foundation
import SwiftUI


struct Position: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var discription: String
    
    private var imageName: String
    var image: Image{
        Image(imageName)
    }
    
    init(){
        self.id = 0
        self.name = "none"
        self.discription = "none"
        self.imageName = "Sample"
    }
    
    init(id: Int, name: String, discription: String, imageName: String){
        self.id = id
        self.name = name
        self.discription = discription
        self.imageName = imageName
    }
    
    init(id: Int, name: String, imageName: String){
        self.id = id
        self.name = name
        self.discription = "none"
        self.imageName = imageName
    }
}
