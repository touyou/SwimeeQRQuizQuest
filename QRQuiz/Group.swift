//
//  Group.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/18.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation

class Group {
    var id: String
    var score: Int
    
    init(id: String, score: Int) {
        self.id = id
        self.score = score
    }
}
