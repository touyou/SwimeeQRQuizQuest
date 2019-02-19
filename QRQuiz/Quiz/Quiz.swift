//
//  Quiz.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/19.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation

class Quiz {
    var question: String
    var correct: String
    var wrong: [String]
    
    init(question: String, correct: String, wrong: [String]) {
        self.question = question
        self.correct = correct
        self.wrong = wrong
    }
    
    
}
