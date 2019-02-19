//
//  UIColor+QRQuiz.swift
//  QRQuiz
//
//  Created by 藤井陽介 on 2019/02/19.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit

extension UIColor {

    // MARK: - QRQuiz Colors
    struct QRQuiz {
        static let mainRed = UIColor(hex: "#CC353E")
        static let buttonBlue = UIColor(hex: "#1F2452")
        static let textBlack = UIColor(hex: "#2B2B2B")
    }
}

// MARK: - Initialization Extensions
extension UIColor {

    convenience init(hex: String) {

        let colorString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased().filter { "#" != $0 }
        let alpha: CGFloat = colorString.count == 6 ? 1.0 : 0.0
        var rgb: UInt32 = 0
        Scanner(string: colorString).scanHexInt32(&rgb)

        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: alpha)
    }
}

