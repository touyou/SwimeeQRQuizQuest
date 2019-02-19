//
//  UserManager.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/16.
//  Copyright © 2019 張翔. All rights reserved.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa
import Firebase
import FirebaseAuth

class UserManager {
    static let shared = UserManager()
    
    let db = Firestore.firestore()
    
    private var user: User? {
        return Auth.auth().currentUser
    }
    
    var isLoggedin: Bool {
        return user != nil
    }
    
    private let allUserRelay = BehaviorRelay<[Member]>(value: [])
    var allUser: Observable<[Member]> {
        return allUserRelay.asObservable()
    }
    
    private var usersMemberDataRelay = BehaviorRelay<Member?>(value: nil)
    var usersMemberData: Observable<Member?> {
        return usersMemberDataRelay.asObservable()
    }
    
    var usersIdListener: ListenerRegistration?
    var usersMemberDataListener: ListenerRegistration?
    
    private init(){
        startListenAllMember()
    }
    
    func startListenAllMember() {
        db.collection("Member").addSnapshotListener {[weak self] (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var tempAllUser = self?.allUserRelay.value ?? []
            snapshot.documentChanges.forEach {diff in
                let data = diff.document.data()
                guard let name = data["name"] as? String,
                    let group = data["group"] as? String,
                    let imageString = data["imageRef"] as? String,
                    let id = Int(diff.document.documentID)
                    else {
                        return
                }
                if (diff.type == .added) {
                    let member = Member(id: id, name: name, group: group, imageString: imageString)
                    tempAllUser.append(member)
                }
                if (diff.type == .modified) {
                    tempAllUser.filter{$0.id == id}.first?
                        .update(name: name, group: group, imageString: imageString)
                }
                if (diff.type == .removed) {
                    if let index = tempAllUser
                        .firstIndex(of: tempAllUser.filter{$0.id == id}.first!) {
                        tempAllUser.remove(at: index)
                    }
                }
            }
            self?.allUserRelay.accept(tempAllUser)
        }
        
    }
    
    func login(member: Member) -> Observable<User>{
        return Observable.create({[weak self] (observer) -> Disposable in
            Auth.auth().signInAnonymously(completion: { (result, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    let uid = result?.user.uid
                    self?.db.collection("User").document(uid!).setData(["id": member.id], completion: { (error) in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext((self?.user!)!)
                            observer.onCompleted()
                            self?.startListening()
                        }
                    })
                }
            })
            return Disposables.create()
        })
    }
    
    func startListening() {
        guard let user = user else {
            return
        }
        if let usersIdListener = usersIdListener {
            usersIdListener.remove()
        }
        usersIdListener = db.collection("User").document(user.uid).addSnapshotListener {[weak self] (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data(),
                let id = data["id"] as? Int else {
                    return
            }
            self?.listenUsersMemberData(id: id)
        }
    }
    
    func listenUsersMemberData(id: Int) {
        if let usersMemberDataListener = usersMemberDataListener {
            usersMemberDataListener.remove()
        }
        usersMemberDataListener = db.collection("Member").document(String(id)).addSnapshotListener {[weak self] (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data(),
                let name = data["name"] as? String,
                let group = data["group"] as? String,
                let imageString = data["imageRef"] as? String
                else {
                    return
            }
            let member = Member(id: id, name: name, group: group, imageString: imageString)
            self?.usersMemberDataRelay.accept(member)
            GroupManager.shared.startListening(groupID: group)
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
}
