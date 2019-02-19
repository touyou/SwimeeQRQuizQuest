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
    
    private let quizCollectionArrayRelay = BehaviorRelay<[QuizCollection]>(value: [])
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
}
