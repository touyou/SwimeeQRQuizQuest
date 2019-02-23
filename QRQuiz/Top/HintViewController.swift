//
//  HintViewController.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/23.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit

class HintViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var firstHintLabel: UILabel!
    @IBOutlet var secondHintLabel: UILabel!
    @IBOutlet var thirdHintLabel: UILabel!
    
    var quizCollection: QuizCollection!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = "\(quizCollection.name)の手がかり"
        firstHintLabel.text = quizCollection.hint[0]
        secondHintLabel.text = quizCollection.hint[1]
        thirdHintLabel.text = quizCollection.hint[2]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setupBarColor()
    }
    
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
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
