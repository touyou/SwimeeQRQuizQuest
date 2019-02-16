//
//  Member.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/16.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation
import Firebase

class Member {
    var id: Int
    var name: String
    var group: String
    var imageRef: StorageReference
    
    init(id: Int, name: String, group: String, imageString: String) {
        self.id = id
        self.name = name
        self.group = group
        self.imageRef = Storage.storage().reference(withPath: imageString)
    }
    
    func update(name: String, group: String, imageString: String) {
        self.name = name
        self.group = group
        self.imageRef = Storage.storage().reference(withPath: imageString)
    }
    
}

extension Member: Equatable {
    static func == (lhs: Member, rhs: Member) -> Bool {
        return lhs.id == rhs.id
    }
}
