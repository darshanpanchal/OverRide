//
//  ChildSummaryCollectionViewCell.swift
//  TeenageSafety
//
//  Created by user on 20/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ChildSummaryCollectionViewCell: UICollectionViewCell {

    @IBOutlet var containerView:UIView!
    
    @IBOutlet var buttonChildScore:UIButton!
    
    @IBOutlet var lblChildName:UILabel!
    @IBOutlet var buttonChild:RoundButton!
    
    @IBOutlet var buttonViewDiagnosis:UIButton!
    @IBOutlet var lblChildScore:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.clipsToBounds = true
        self.buttonChildScore.layer.borderWidth = 1.5
        self.buttonChildScore.layer.cornerRadius = 14.5
        self.buttonChildScore.clipsToBounds = true
        self.buttonChildScore.layer.borderColor = UIColor.white.cgColor
    }

}
