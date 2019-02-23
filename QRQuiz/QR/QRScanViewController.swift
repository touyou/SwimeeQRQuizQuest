//
//  QRScanViewController.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/23.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import Firebase
import FirebaseFirestore

class QRScanViewController: UIViewController {
    
    let qrScaner = QRScaner()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrScaner.setupQRScan()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: qrScaner.session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        observeFoundQR()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setupBarColor()
        qrScaner.startQRScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrScaner.stopQRScan()
    }
    
    func observeFoundQR() {
        qrScaner.foundQR
            .withLatestFrom(GroupManager.shared.currentGroup) {(qrString, group) -> (String, Group?) in
                return (qrString, group)
            }
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: {[weak self] (qrString, group) in
                guard let group = group else {
                    return
                }
                guard let qrInt = Int(qrString),
                    let state = group.quizState[qrInt],
                    state == QuizState.scanableBack || state == QuizState.scanableNext
                else {
                    self?.showAlert(title: "このQRコードではないようだ...")
                    return
                }
                if state == QuizState.scanableNext {
                    GroupManager.shared.scannedScanableNext(collectionID: qrInt)
                    self?.showAlert(title: "クイズを回答できるようになった！ホーム画面から確認しよう！")
                } else if state == QuizState.scanableBack {
                    GroupManager.shared.scannedScanableBack(collectionID: qrInt)
                    self?.showAlert(title: "新しいクイズの手がかりを手に入れた！ホーム画面から確認しよう！")
                }
            }).disposed(by: disposeBag)
        
    }
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    
    
    
}
