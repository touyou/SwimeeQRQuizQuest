//
//  UIImage+Extensions.swift
//  QRQuiz
//
//  Created by 藤井陽介 on 2019/02/23.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit

extension UIImage {

    struct Gems {
        // MARK: Got Gems
        static let jewel0 = #imageLiteral(resourceName: "jewel_rect_1")
        static let jewel1 = #imageLiteral(resourceName: "jewel_hex_1")
        static let jewel2 = #imageLiteral(resourceName: "jewel_long_hex_2")
        static let jewel3 = #imageLiteral(resourceName: "jewel_star_2")
        static let jewel4 = #imageLiteral(resourceName: "jewel_dia_2")
        static let jewel5 = #imageLiteral(resourceName: "jewel_cdia_2")
        static let jewel6 = #imageLiteral(resourceName: "jewel_rect_2")
        static let jewel7 = #imageLiteral(resourceName: "jewel_hex_2")
        static let jewel8 = #imageLiteral(resourceName: "jewel_long_hex_1")
        static let jewel9 = #imageLiteral(resourceName: "jewel_dia_1")
        static let jewel10 = #imageLiteral(resourceName: "jewel_dia_1")
        static let jewel11 = #imageLiteral(resourceName: "jewel_cdia_1")

        // MARK: Empty Gems
        static let empty0 = #imageLiteral(resourceName: "jewel_rect_gray")
        static let empty1 = #imageLiteral(resourceName: "jewel_hex_gray")
        static let empty2 = #imageLiteral(resourceName: "jewel_long_hex_gray")
        static let empty3 = #imageLiteral(resourceName: "jewel_star_gray")
        static let empty4 = #imageLiteral(resourceName: "jewel_dia_gray")
        static let empty5 = #imageLiteral(resourceName: "jewel_cdia_gray")
    }

    static func jewelImage(_ id: Int, with state: QuizState) -> UIImage {


    }
}
