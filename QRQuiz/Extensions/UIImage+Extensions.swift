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
        static let jewel0 = #imageLiteral(resourceName: "jewel12")
        static let jewel1 = #imageLiteral(resourceName: "jewel6")
        static let jewel2 = #imageLiteral(resourceName: "jewel10")
        static let jewel3 = #imageLiteral(resourceName: "jewel16")
        static let jewel4 = #imageLiteral(resourceName: "jewel4")
        static let jewel5 = #imageLiteral(resourceName: "jewel1")
        static let jewel6 = #imageLiteral(resourceName: "jewel13")
        static let jewel7 = #imageLiteral(resourceName: "jewel7")
        static let jewel8 = #imageLiteral(resourceName: "jewel9")
        static let jewel9 = #imageLiteral(resourceName: "jewel15")
        static let jewel10 = #imageLiteral(resourceName: "jewel3")
        static let jewel11 = #imageLiteral(resourceName: "jewel0")

        // MARK: Empty Gems
        static let empty0 = #imageLiteral(resourceName: "jewel14")
        static let empty1 = #imageLiteral(resourceName: "jewel8")
        static let empty2 = #imageLiteral(resourceName: "jewel11")
        static let empty3 = #imageLiteral(resourceName: "jewel17")
        static let empty4 = #imageLiteral(resourceName: "jewel5")
        static let empty5 = #imageLiteral(resourceName: "jewel2")

        static let none = #imageLiteral(resourceName: "none_jewel")
    }

    static func jewelImage(_ id: Int, with state: QuizState) -> UIImage {

        switch state {
        case .gotGem, .gotGemLast, .scanableBack:
            switch id {
            case 0: return Gems.jewel0
            case 1: return Gems.jewel1
            case 2: return Gems.jewel2
            case 3: return Gems.jewel3
            case 4: return Gems.jewel4
            case 5: return Gems.jewel5
            case 6: return Gems.jewel6
            case 7: return Gems.jewel7
            case 8: return Gems.jewel8
            case 9: return Gems.jewel9
            case 10: return Gems.jewel10
            case 11: return Gems.jewel11
            default: return Gems.none
            }
        case .none:
            return Gems.none
        default:
            switch id % 6 {
            case 0: return Gems.empty0
            case 1: return Gems.empty1
            case 2: return Gems.empty2
            case 3: return Gems.empty3
            case 4: return Gems.empty4
            case 5: return Gems.empty5
            default: return Gems.none
            }
        }
    }
}
