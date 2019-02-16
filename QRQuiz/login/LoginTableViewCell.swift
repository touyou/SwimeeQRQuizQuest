//
//  LoginTableViewCell.swift
//  QRQuiz
//
//  Created by 張翔 on 2019/02/16.
//  Copyright © 2019 張翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class LoginTableViewCell: UITableViewCell {
    
    @IBOutlet var memberImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(_ member: Member) {
        memberImageView.sd_setImage(with: member.imageRef)
        nameLabel.text = member.name
    }

}
