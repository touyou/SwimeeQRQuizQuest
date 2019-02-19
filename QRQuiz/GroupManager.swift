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
    
    private let currentGroupRelay = BehaviorRelay<Group?>(value: nil)
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
                let score = data["score"] as? Int
                else {
                    return
            }
            let group = Group(id: groupID, score: score)
            self?.currentGroupRelay.accept(group)
        }
        
    }
}
