//
//  ResultViewController.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/19.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ResultViewController: UIViewController {
    
    @IBOutlet var finalScoreLabel: UILabel!
    @IBOutlet var nextQuizLabel: UILabel!
    @IBOutlet var firstHintLabel: UILabel!
    @IBOutlet var secondHintLabel: UILabel!
    @IBOutlet var thirdHintLabel: UILabel!
    @IBOutlet var finishButton:  UIButton!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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
                    self?.dismiss(animated: true, completion: nil)
                case .showAnswer:
                    self?.dismiss(animated: true, completion: nil)
                case .result:
                    if let answerer = group.viewControllerState.answerer {
                        if answerer == UserManager.shared.usersMemberDataRelay.value?.id {
                            self?.finishButton.isEnabled = true
                        } else {
                            self?.finishButton.isEnabled = false
                        }
                    }
                    self?.finalScoreLabel.text = "正解数:\(group.viewControllerState.score!)/5"
                    if group.viewControllerState.score! >= 3{
                        let nextQuizCollectionID = group.quizState.filter({ (state) -> Bool in
                            return state.value == QuizState.scanableNext
                        }).first?.key
                        let nextQuizCollection = QuizManager.shared.quizCollectionArrayRelay.value.filter({ (quizCollection) -> Bool in
                            return quizCollection.id == nextQuizCollectionID
                        }).first!
                        self?.nextQuizLabel.text = "ノルマを達成しました！次のクイズは\(nextQuizCollection.name)です！以下は\(nextQuizCollection.name)の手がかりです！"
                        self?.firstHintLabel.text = nextQuizCollection.hint[0]
                        self?.secondHintLabel.text = nextQuizCollection.hint[1]
                        self?.thirdHintLabel.text = nextQuizCollection.hint[2]
                    } else {
                        let nextQuizCollectionID = group.quizState.filter({ (state) -> Bool in
                            return state.value == QuizState.scanableBack
                        }).first?.key
                        let nextQuizCollection = QuizManager.shared.quizCollectionArrayRelay.value.filter({ (quizCollection) -> Bool in
                            return quizCollection.id == nextQuizCollectionID
                        }).first!
                        self?.nextQuizLabel.text = "ノルマを達成出来ませんでした。一つ前の\(nextQuizCollection.name)のQRをスキャンして次の問題を開放してください。以下は\(nextQuizCollection.name)の手がかりです！"
                        self?.firstHintLabel.text = nextQuizCollection.hint[0]
                        self?.secondHintLabel.text = nextQuizCollection.hint[1]
                        self?.thirdHintLabel.text = nextQuizCollection.hint[2]
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    @IBAction func finish() {
        QuizManager.shared.finishQuiz()
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
