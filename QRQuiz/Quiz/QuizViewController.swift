//
//  QuizViewController.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/19.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class QuizViewController: UIViewController {
    
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var firstImageView: UIImageView!
    @IBOutlet var secondImageView: UIImageView!
    @IBOutlet var thirdImageView: UIImageView!
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var thirdLabel: UILabel!
    @IBOutlet var firstButton: UIButton!
    @IBOutlet var secondButton: UIButton!
    @IBOutlet var thirdButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var answererLabel: UILabel!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindData()
    }
    
    func bindData() {
        GroupManager.shared.currentGroup
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: { [weak self](group) in
                guard let group = group else {
                    return
                }
                switch group.viewControllerState.type {
                case .notAnswering:
                    self?.dismiss(animated: true, completion: nil)
                case .answering:
                    self?.firstImageView.image = #imageLiteral(resourceName: "selection_1")
                    self?.secondImageView.image = #imageLiteral(resourceName: "selection_2")
                    self?.thirdImageView.image = #imageLiteral(resourceName: "selection_3")
                    if let choise = group.viewControllerState.choise {
                        self?.firstLabel.text = choise[0]
                        self?.secondLabel.text = choise[1]
                        self?.thirdLabel.text = choise[2]
                    }
                    if let question = group.viewControllerState.question {
                        self?.questionLabel.text = question
                    }
                    if let answerer = group.viewControllerState.answerer {
                        if answerer == UserManager.shared.usersMemberDataRelay.value?.id {
                            self?.firstButton.isEnabled = true
                            self?.secondButton.isEnabled = true
                            self?.thirdButton.isEnabled = true
                        } else {
                            self?.firstButton.isEnabled = false
                            self?.secondButton.isEnabled = false
                            self?.thirdButton.isEnabled = false
                        }
                        if let answererName = UserManager.shared.allUserRelay.value.filter({ (member) -> Bool in
                            return member.id == answerer
                        }).first?.name {
                            self?.answererLabel.text = "\(answererName)のみ解答可能"
                        }
                    }
                    self?.nextButton.isEnabled = false
                   
                case .showAnswer:
                    if let choise = group.viewControllerState.choise {
                        self?.firstLabel.text = choise[0]
                        self?.secondLabel.text = choise[1]
                        self?.thirdLabel.text = choise[2]
                    }
                    if let question = group.viewControllerState.question {
                        self?.questionLabel.text = question
                    }
                    if let answer = group.viewControllerState.answer {
                        var imageViews: [UIImageView?] = [self?.firstImageView, self?.secondImageView, self?.thirdImageView]
                        imageViews[answer]?.image = #imageLiteral(resourceName: "check")
                        imageViews.remove(at: answer)
                        for imageView in imageViews {
                            imageView?.image = #imageLiteral(resourceName: "close")
                        }
                    }
                    self?.firstButton.isEnabled = false
                    self?.secondButton.isEnabled = false
                    self?.thirdButton.isEnabled = false
                    if let answerer = group.viewControllerState.answerer {
                        if answerer == UserManager.shared.usersMemberDataRelay.value?.id {
                            self?.nextButton.isEnabled = true
                        } else {
                            self?.nextButton.isEnabled = false
                        }
                        if let answererName = UserManager.shared.allUserRelay.value.filter({ (member) -> Bool in
                            return member.id == answerer
                        }).first?.name {
                            self?.answererLabel.text = "\(answererName)のみ解答可能"
                        }
                    }
                case .result:
                    self?.performSegue(withIdentifier: "result", sender: nil)
                }
            }).disposed(by: disposeBag)
    }
    
    @IBAction func first() {
        QuizManager.shared.selectAnswer(selected: 0)
    }
    
    @IBAction func second() {
        QuizManager.shared.selectAnswer(selected: 1)
    }
    
    @IBAction func third() {
        QuizManager.shared.selectAnswer(selected: 2)
    }
    
    @IBAction func next() {
        QuizManager.shared.nextQuiz()
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
