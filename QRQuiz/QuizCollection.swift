//
//  QuizCollection.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/18.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation

class QuizCollection {
    var name: String
    var quizzes: [Quiz]
    var score: Int
    var level: Int
    var hint: [String]
    
    init(name: String, quizzes: [Quiz]?, score: Int, level: Int, hint: ) {
        self.name = name
        if let quizzes = quizzes {
            self.quizzes = quizzes
        } else {
            self.quizzes = []
        }
    }
}
