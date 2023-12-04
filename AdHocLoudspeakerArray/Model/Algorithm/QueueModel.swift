//
//  QueueModel.swift
//  AdHocLoudspeakerArray
//
//  Created by 藤田一旗 on 2023/11/28.
//

import Foundation

class QueueModel<T> : NSObject {
    
    var array = [T]()
    
    init(array: [T]){
        self.array = array
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var size: Int{
        return self.array.count
    }
    
    public func enqueue(element: T) {
        self.array.append(element)
    }

    public func dequeue() -> T? {
        if self.array.isEmpty {
          return nil
        } else {
          return array.removeFirst()
        }
    }
    
}
