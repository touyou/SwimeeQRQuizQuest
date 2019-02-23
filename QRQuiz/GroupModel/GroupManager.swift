//
//  GroupManager.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/18.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation
import Firebase
import RxCocoa
import RxSwift

class GroupManager {
    static let shared = GroupManager()
    
    let db = Firestore.firestore()
    
    private init(){
    }
    
    let currentGroupRelay = BehaviorRelay<Group?>(value: nil)
    var currentGroup: Observable<Group?> {
        return currentGroupRelay.asObservable()
    }
    
    private var groupListener: ListenerRegistration?
    
    func startListening(groupID: String) {
        if let groupListener = groupListener {
            groupListener.remove()
        }
        groupListener = db.collection("Group").document(groupID).addSnapshotListener {[weak self] (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data(),
                let score = data["score"] as? Int,
                let rawQuizState = data["quizState"] as? [String: String],
                let quizState = self?.createQuizState(dataDictionaly: rawQuizState),
                let rawViewControllerState = data["viewControllerState"] as? [String: Any],
                let viewControllerState = self?.createViewControllerState(dataDictionaly: rawViewControllerState)
                else {
                    return
            }
            let group = Group(id: groupID, score: score, quizState: quizState, viewControllerState: viewControllerState)
            self?.currentGroupRelay.accept(group)
            if group.viewControllerState.type != .notAnswering {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Quiz")
                UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    func createQuizState(dataDictionaly: [String: String]) -> [Int: QuizState] {
        var quizState: [Int: QuizState] = [:]
        for data in dataDictionaly {
            guard let state = QuizState(rawValue: data.value),
                let id = Int(data.key)
                else {
                continue
            }
            quizState.updateValue(state, forKey: id)
        }
        return quizState
    }
    
    func createViewControllerState(dataDictionaly: [String: Any]) -> ViewControllerState? {
        guard let type = ViewControllerStateType(rawValue: dataDictionaly["type"] as! String) else {
            return nil
        }
        let quizCollectionID = dataDictionaly["quizCollectionID"] as? Int
        let quizID = dataDictionaly["quizID"] as? Int
        let choise = dataDictionaly["choise"] as? [String]
        let answer = dataDictionaly["answer"] as? Int
        let selected = dataDictionaly["selected"] as? Int
        let answerer = dataDictionaly["answerer"] as? Int
        let question = dataDictionaly["question"] as? String
        let score = dataDictionaly["score"] as? Int
        let next = dataDictionaly["next"] as? Int
        return ViewControllerState(type: type, quizCollectionID: quizCollectionID, quizID: quizID, choise: choise, answer: answer, selected: selected, answerer: answerer, question: question, score: score, next: next)
    }
    
    func scannedScanableNext(collectionID: Int) {
        guard let groupID = GroupManager.shared.currentGroupRelay.value?.id else {
            return
        }
        var quizState = GroupManager.shared.currentGroupRelay.value?.quizState
        quizState?.updateValue(.answerable, forKey: collectionID)
        var quizStateString: [String:String] = [:]
        for data in quizState! {
            let state = data.value.rawValue
            quizStateString.updateValue(state, forKey: String(data.key))
        }
        db.collection("Group").document(groupID).updateData([
            "quizState": quizStateString
        ])
    }
    
    func scannedScanableBack(collectionID: Int) {
        guard let groupID = GroupManager.shared.currentGroupRelay.value?.id else {
            return
        }
        var quizState = GroupManager.shared.currentGroupRelay.value?.quizState
        quizState?.updateValue(.gotGemLast, forKey: collectionID)
        var nextQuizCollectionID: Int!
        var quizCollectionArray = QuizManager.shared.quizCollectionArrayRelay.value
        repeat{
            let nextQuizCollection = quizCollectionArray.randomElement()
            nextQuizCollectionID = nextQuizCollection?.id
            quizCollectionArray.remove(at: quizCollectionArray.firstIndex(of: nextQuizCollection!)!)
            if quizCollectionArray.count == 0 {
                var quizStateString: [String:String] = [:]
                for data in quizState! {
                    let state = data.value.rawValue
                    quizStateString.updateValue(state, forKey: String(data.key))
                }
                db.collection("Group").document(groupID).updateData([
                    "quizState": quizStateString
                ])
                return
            }
        }while GroupManager.shared.currentGroupRelay.value?.quizState[nextQuizCollectionID] != nil && GroupManager.shared.currentGroupRelay.value?.quizState[nextQuizCollectionID] != QuizState.none
        quizState?.updateValue(.scanableNext, forKey: nextQuizCollectionID)
        var quizStateString: [String:String] = [:]
        for data in quizState! {
            let state = data.value.rawValue
            quizStateString.updateValue(state, forKey: String(data.key))
        }
        db.collection("Group").document(groupID).updateData([
            "quizState": quizStateString
        ])
    }
}
