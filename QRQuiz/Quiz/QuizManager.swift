//
//  QuizManager.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/18.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Firebase

class QuizManager {
    static let shared = QuizManager()
    
    private init(){
        startListening()
    }
    
    let quizCollectionArrayRelay = BehaviorRelay<[QuizCollection]>(value: [])
    var quizCollectionArray: Observable<[QuizCollection]> {
        return quizCollectionArrayRelay.asObservable()
    }
    
    let db = Firestore.firestore()
    
    private var quizCollectionArrayListener: ListenerRegistration?
    
    func startListening() {
        if let quizCollectionArrayListener = quizCollectionArrayListener {
            quizCollectionArrayListener.remove()
        }
        quizCollectionArrayListener = db.collection("Quiz").addSnapshotListener {[weak self] (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var tempQuizCollectionArray = self?.quizCollectionArrayRelay.value ?? []
            snapshot.documentChanges.forEach {diff in
                let data = diff.document.data()
                guard let name = data["name"] as? String,
                    let score = data["score"] as? Int,
                    let level = data["level"] as? Int,
                    let hint = data["hint"] as? [String],
                    let id = Int(diff.document.documentID),
                    let rawQuizzes = data["quizzes"] as? [[String: Any]],
                    let quizzes = self?.createQuizzes(dataArray: rawQuizzes)
                    else {
                        return
                }
                if (diff.type == .added) {
                    let quizCollection = QuizCollection(id: id, name: name, quizzes: quizzes, score: score, level: level, hint: hint)
                    tempQuizCollectionArray.append(quizCollection)
                }
                if (diff.type == .modified) {
                    tempQuizCollectionArray.filter{$0.id == id}.first?
                        .update(name: name, quizzes: quizzes, score: score, level: level, hint: hint)
                }
                if (diff.type == .removed) {
                    if let index = tempQuizCollectionArray
                        .firstIndex(of: tempQuizCollectionArray.filter{$0.id == id}.first!) {
                        tempQuizCollectionArray.remove(at: index)
                    }
                }
            }
            self?.quizCollectionArrayRelay.accept(tempQuizCollectionArray.sorted())
        }
    }
    
    func createQuizzes(dataArray: [[String: Any]]) -> [Quiz] {
        var quizzes: [Quiz] = []
        for data in dataArray {
            guard let question = data["question"] as? String,
                let correct = data["correct"] as? String,
                let wrong = data["wrong"] as? [String]
                else {
                    continue
            }
            let quiz = Quiz(question: question, correct: correct, wrong: wrong)
            quizzes.append(quiz)
        }
        return quizzes
    }
    
    func showQuiz(index: Int) {
        let collection = quizCollectionArrayRelay.value[index]
        guard let groupID = GroupManager.shared.currentGroupRelay.value?.id else {
            return
        }
        let answer = Int.random(in: 0..<3)
        var choise = collection.quizzes[0].wrong
        choise.insert(collection.quizzes[0].correct, at: answer)
        db.collection("Group").document(groupID).updateData([
            "viewControllerState": [
                "type": ViewControllerStateType.answering.rawValue,
                "question": collection.quizzes[0].question,
                "answer": answer,
                "choise": choise,
                "quizCollectionID": collection.id,
                "quizID": 0,
                "answerer": UserManager.shared.usersMemberDataRelay.value!.id
            ]
        ])
    }
    
    func selectAnswer(selected: Int) {
        guard let viewControllerState = GroupManager.shared.currentGroupRelay.value?.viewControllerState else {
            return
        }
        guard let groupID = GroupManager.shared.currentGroupRelay.value?.id else {
            return
        }
        var score = GroupManager.shared.currentGroupRelay.value?.viewControllerState.score ?? 0
        if selected == viewControllerState.answer {
            score += 1
        }
        db.collection("Group").document(groupID).updateData([
            "viewControllerState": [
                "type": ViewControllerStateType.showAnswer.rawValue,
                "question": viewControllerState.question as Any,
                "answer": viewControllerState.answer as Any,
                "choise": viewControllerState.choise as Any,
                "quizCollectionID": viewControllerState.quizCollectionID as Any,
                "quizID": viewControllerState.quizID as Any,
                "answerer": UserManager.shared.usersMemberDataRelay.value!.id,
                "selected": selected,
                "score": score
            ]
            ])
    }
    
    func nextQuiz() {
        guard let viewControllerState = GroupManager.shared.currentGroupRelay.value?.viewControllerState else {
            return
        }
        guard let groupID = GroupManager.shared.currentGroupRelay.value?.id else {
            return
        }
        guard let collection = quizCollectionArrayRelay.value.filter({ (quizCollection) -> Bool in
            return quizCollection.id == viewControllerState.quizCollectionID
        }).first else {
            return
        }
        if viewControllerState.quizID! + 1 != collection.quizzes.count {
            let answer = Int.random(in: 0..<3)
            var choise = collection.quizzes[viewControllerState.quizID! + 1].wrong
            choise.insert(collection.quizzes[viewControllerState.quizID! + 1].correct, at: answer)
            db.collection("Group").document(groupID).updateData([
                "viewControllerState": [
                    "type": ViewControllerStateType.answering.rawValue,
                    "question": collection.quizzes[viewControllerState.quizID! + 1].question,
                    "answer": answer,
                    "choise": choise,
                    "quizCollectionID": viewControllerState.quizCollectionID as Any,
                    "quizID": viewControllerState.quizID! + 1,
                    "answerer": UserManager.shared.usersMemberDataRelay.value!.id,
                    "score": viewControllerState.score!
                ]
            ])
        } else {
            if viewControllerState.score! >= 3 {
                var nextQuizCollectionID: Int!
                var quizCollectionArray = quizCollectionArrayRelay.value
                repeat{
                    let nextQuizCollection = quizCollectionArray.randomElement()
                    nextQuizCollectionID = nextQuizCollection?.id
                    quizCollectionArray.remove(at: quizCollectionArray.firstIndex(of: nextQuizCollection!)!)
                    if quizCollectionArray.count == 0 {
                        var quizState = GroupManager.shared.currentGroupRelay.value?.quizState
                        for data in quizState! {
                            if data.value == .gotGemLast {
                                quizState?.updateValue(.gotGem, forKey: data.key)
                            }
                        }
                        quizState?.updateValue(.gotGemLast, forKey: collection.id)
                        var quizStateString: [String:String] = [:]
                        for data in quizState! {
                            let state = data.value.rawValue
                            quizStateString.updateValue(state, forKey: String(data.key))
                        }
                        db.collection("Group").document(groupID).updateData([
                            "quizState": quizStateString
                        ]) { (error) in
                            if error == nil {
                                self.db.collection("Group").document(groupID).updateData([
                                    "viewControllerState": [
                                        "type": ViewControllerStateType.notAnswering.rawValue,
                                    ]
                                ])
                            }
                        }
                        db.collection("Group").document(groupID).updateData([
                            "score": GroupManager.shared.currentGroupRelay.value!.score + (collection.score * viewControllerState.score!)
                        ])
                        return
                    }
                }while GroupManager.shared.currentGroupRelay.value?.quizState[nextQuizCollectionID] != nil && GroupManager.shared.currentGroupRelay.value?.quizState[nextQuizCollectionID] != QuizState.none
                var quizState = GroupManager.shared.currentGroupRelay.value?.quizState
                quizState?.updateValue(.scanableNext, forKey: nextQuizCollectionID)
                for data in quizState! {
                    if data.value == .gotGemLast {
                        quizState?.updateValue(.gotGem, forKey: data.key)
                    }
                }
                quizState?.updateValue(.gotGemLast, forKey: collection.id)
                var quizStateString: [String:String] = [:]
                for data in quizState! {
                    let state = data.value.rawValue
                    quizStateString.updateValue(state, forKey: String(data.key))
                }
                db.collection("Group").document(groupID).updateData([
                    "quizState": quizStateString
                ]) { (error) in
                    if error == nil {
                        self.db.collection("Group").document(groupID).updateData([
                            "viewControllerState": [
                                "type": ViewControllerStateType.result.rawValue,
                                "answerer": UserManager.shared.usersMemberDataRelay.value!.id,
                                "score": viewControllerState.score as Any
                            ]
                        ])
                    }
                }
            } else {
                if collection.id == 0 {
                    self.db.collection("Group").document(groupID).updateData([
                        "viewControllerState": [
                            "type": ViewControllerStateType.notAnswering.rawValue
                        ]
                    ])
                    return
                }
                let nextQuizCollectionID = GroupManager.shared.currentGroupRelay.value?.quizState.filter({ (state) -> Bool in
                    return state.value == QuizState.gotGemLast
                }).first!.key
                var quizState = GroupManager.shared.currentGroupRelay.value?.quizState
                quizState?.updateValue(.scanableBack, forKey: nextQuizCollectionID!)
                quizState?.updateValue(.couldnotGet, forKey: collection.id)
                var quizStateString: [String:String] = [:]
                for data in quizState! {
                    let state = data.value.rawValue
                    quizStateString.updateValue(state, forKey: String(data.key))
                }
                db.collection("Group").document(groupID).updateData([
                    "quizState": quizStateString
                ]) { (error) in
                    if error == nil {
                        self.db.collection("Group").document(groupID).updateData([
                            "viewControllerState": [
                                "type": ViewControllerStateType.result.rawValue,
                                "answerer": UserManager.shared.usersMemberDataRelay.value!.id,
                                "score": viewControllerState.score as Any
                            ]
                            ])
                    }
                }
            }
            db.collection("Group").document(groupID).updateData([
                "score": GroupManager.shared.currentGroupRelay.value!.score + (collection.score * viewControllerState.score!)
            ])
            
        }
    }
    
    func finishQuiz() {
        guard let groupID = GroupManager.shared.currentGroupRelay.value?.id else {
            return
        }
        self.db.collection("Group").document(groupID).updateData([
            "viewControllerState": [
                "type": ViewControllerStateType.notAnswering.rawValue
            ]
            ])
    }
}
