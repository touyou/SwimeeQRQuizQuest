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
    @IBOutlet var collectionView: UICollectionView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setupBarColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserManager.shared.isLoggedin {
            let loginViewController = storyboard?.instantiateViewController(withIdentifier: "Login")
            present(loginViewController!, animated: true, completion: nil)
        }
        
        collectionView.reloadData()
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
        
        Observable.combineLatest(QuizManager.shared.quizCollectionArray, GroupManager.shared.currentGroup) { (quizCollectionArray, currentGroup) -> [(QuizCollection, QuizState)] in
            var tapule: [(QuizCollection, QuizState)] = []
            for quizCollection in quizCollectionArray {
                if let state = currentGroup?.quizState[quizCollection.id] {
                    tapule.append((quizCollection, state))
                } else {
                    tapule.append((quizCollection, QuizState.none))
                }
            }
            return tapule
        }
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(collectionView.rx.items(cellIdentifier: "Cell", cellType: TopCollectionViewCell.self)) {row, element, cell in
                cell.label.text = element.0.name
                cell.imageView.image = UIImage.jewelImage(row, with: element.1)
                switch element.1 {
                case .answerable, .scanableBack:
                    cell.imageView.alpha = 1
                    cell.flashing(true)
                case .scanableNext:
                    cell.imageView.alpha = 0.3
                    cell.flashing(true)
                case .couldnotGet:
                    cell.imageView.alpha = 0.3
                    cell.flashing(false)
                case .none, .gotGemLast, .gotGem:
                    cell.imageView.alpha = 1
                    cell.flashing(false)
                }
            }
            .disposed(by: disposeBag)
        
        collectionView.rx
            .itemSelected
            .withLatestFrom(GroupManager.shared.currentGroup) {(indexPath, group) -> (IndexPath, QuizState) in
                if let state = group?.quizState[indexPath.row] {
                    return (indexPath, state)
                } else {
                    return (indexPath, QuizState.none)
                }
            }
            .subscribe(onNext: {[weak self] (indexPath, state) in
                switch state {
                case .answerable:
                    QuizManager.shared.showQuiz(index: indexPath.row)
                case .scanableNext:
                    let nc = self?.storyboard?.instantiateViewController(withIdentifier: "Hint") as! UINavigationController
                    let vc = nc.viewControllers.first! as! HintViewController
                    vc.quizCollection = QuizManager.shared.quizCollectionArrayRelay.value[indexPath.row]
                    self?.present(nc, animated: true, completion: nil)
                case .scanableBack:
                    let nc = self?.storyboard?.instantiateViewController(withIdentifier: "Hint") as! UINavigationController
                    let vc = nc.viewControllers.first! as! HintViewController
                    vc.quizCollection = QuizManager.shared.quizCollectionArrayRelay.value[indexPath.row]
                    self?.present(nc, animated: true, completion: nil)
                case .gotGem:
                    break
                case .couldnotGet:
                    break
                case .none:
                    break
                case .gotGemLast:
                    break
                }
            })
            .disposed(by: disposeBag)
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
