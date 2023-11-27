///
///
///Project name: AdHocLoudspeakerArray
/// Class name: StackModel
/// Creator: Kazuki Fujita
/// Update: 2023/11/27 (Mon)
///
/// ---Explanation---
/// StackModel
///
///

import Foundation

class StackModel<T> : NSObject {
    
    var array = [T]()
    
     init(array: [T]){
         self.array = array
    }
    
    public var isEmpty: Bool {
      return array.isEmpty
    }
    
    public var size: Int{
        return array.count
    }
    
    public var peek: T? {
      return array.last
    }

    public func push(element: T) {
      array.append(element)
    }
    
    public func pushArray(elements: [T]) {
        array.append(contentsOf: elements)
    }

    public func pop() -> T? {
      return array.popLast()
    }
}
