//
//  TopViewController.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/16.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseUI

class TopViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var groupLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var memberImageView: UIImageView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserManager.shared.isLoggedin {
            let loginViewController = storyboard?.instantiateViewController(withIdentifier: "Login")
            present(loginViewController!, animated: true, completion: nil)
        }
    }
    
    func bindData() {
        UserManager.shared.usersMemberData
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: { (member) in
                if let member = member {
                    self.nameLabel.text = member.name
                    self.groupLabel.text = "グループ: \(member.group)"
                    self.memberImageView.sd_setImage(with: member.imageRef, placeholderImage: #imageLiteral(resourceName: "icon_user"))
                } else {
                    self.nameLabel.text = ""
                    self.groupLabel.text = ""
                    self.memberImageView.image = nil
                }
            }).disposed(by: disposeBag)
        
        GroupManager.shared.currentGroup
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: { (group) in
                if let group = group {
                    self.scoreLabel.text = "得点: \(group.score)"
                } else {
                    self.scoreLabel.text = ""
                }
            }).disposed(by: disposeBag)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
