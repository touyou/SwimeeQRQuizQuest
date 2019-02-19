//
//  Group.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/18.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation

enum QuizState: String {
    case answerable
    case scanableNext
    case scanableBack
    case gotGem
    case couldnotGet
    case none
}

class Group {
    var id: String
    var score: Int
    var quizState: [Int: QuizState]
    
    init(id: String, score: Int, quizState: [Int: QuizState]) {
        self.id = id
        self.score = score
        self.quizState = quizState
    }
}
