//
//  TopCollectionViewCell.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/19.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit

class TopCollectionViewCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    func flashing(_ start: Bool) {
        imageView.backgroundColor = UIColor.white
        if start {
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.imageView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            }, completion: nil)
        } else {
            imageView.layer.removeAllAnimations()
        }
    }
    
}
