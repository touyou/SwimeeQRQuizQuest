//
//  LoginViewController.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/16.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func bindTableView() {
        UserManager.shared.allUser.asDriver(onErrorDriveWith: Driver.empty())
            .drive(tableView.rx.items(cellIdentifier: "Cell", cellType: LoginTableViewCell.self)) {row, element, cell in
                cell.setup(element)
        }.disposed(by: disposeBag)
    }
    
    func didSelect() {
        tableView.rx
            .itemSelected
            .withLatestFrom(UserManager.shared.allUser) {indexPath, allUser in
                return (allUser[indexPath.row], indexPath)
            }
            .subscribe(onNext: {[weak self] (member, indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                UserManager.shared
                    .login(member: member)
                    .subscribe(
                        onNext: {user in
                            print(user.uid)
                    },
                        onError: {error in
                            print(error.localizedDescription)
                    },
                        onCompleted: {
                            self?.dismiss(animated: true, completion: nil)
                    }).disposed(by: (self?.disposeBag)!)
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
