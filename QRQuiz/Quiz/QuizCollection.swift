//
//  QuizCollection.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/18.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation

class QuizCollection {
    var id: Int
    var name: String
    var quizzes: [Quiz]
    var score: Int
    var level: Int
    var hint: [String]
    
    init(id: Int, name: String, quizzes: [Quiz], score: Int, level: Int, hint: [String]) {
        self.id = id
        self.name = name
        self.quizzes = quizzes
        self.score = score
        self.level = level
        self.hint = hint
    }
    
    func update(name: String, quizzes: [Quiz], score: Int, level: Int, hint: [String]) {
        self.name = name
        self.quizzes = quizzes
        self.score = score
        self.level = level
        self.hint = hint
    }
}

extension QuizCollection: Equatable {
    static func == (lhs: QuizCollection, rhs: QuizCollection) -> Bool {
        return lhs.id == rhs.id
    }
}

extension QuizCollection: Comparable {
    static func < (lhs: QuizCollection, rhs: QuizCollection) -> Bool {
        return lhs.id < rhs.id
    }
}
