//
//  ViewControllerState.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/19.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation

enum ViewControllerStateType: String {
    case notAnswering
    case answering
    case showAnswer
    case result
}

class ViewControllerState {
    var quizCollectionID: Int?
    var quizID: Int?
    var choise: [String]?
    var answer: Int?
    var selected: Int?
    var type: ViewControllerStateType
    var answerer: Int?
    var question: String?
    var score: Int?
    var next: Int?
    
    init(type: ViewControllerStateType, quizCollectionID: Int?, quizID: Int?, choise: [String]?, answer: Int?, selected: Int?, answerer: Int?, question: String?, score: Int?, next: Int?) {
        self.type = type
        self.quizCollectionID = quizCollectionID
        self.quizID = quizID
        self.choise = choise
        self.answer = answer
        self.selected = selected
        self.answerer = answerer
        self.question = question
        self.score = score
        self.next = next
    }
}
