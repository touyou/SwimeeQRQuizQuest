//
//  UINavigationController+Extensions.swift
//  QRQuiz
//
//  Created by 藤井陽介 on 2019/02/19.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit

// MARK: - Project Layout
extension UINavigationController {

    func setupBarColor() {

        self.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationBar.barTintColor = UIColor.QRQuiz.mainRed
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.backgroundColor = UIColor.QRQuiz.mainRed
    }
}
