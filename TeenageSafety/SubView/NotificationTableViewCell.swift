//
//  NotificationTableViewCell.swift
//  TeenageSafety
//
//  Created by user on 11/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet var containerView:UIView!
    @IBOutlet var objStackView:UIStackView!
    @IBOutlet var subContainerView:UIView!
    @IBOutlet var bottomHeight:NSLayoutConstraint!
    @IBOutlet var expandableView:UIView!
    
    
    @IBOutlet var lblChildName:UILabel!
    @IBOutlet var lblTime:UILabel!
    @IBOutlet var lblAppName:UILabel!
    @IBOutlet var buttonChild:RoundButton!
    @IBOutlet var buttonApp:RoundCornerButton!
    @IBOutlet var buttonChildCollapase:RoundCornerButton!
    
    @IBOutlet var buttonAccept:UIButton!
    @IBOutlet var buttonDecline:UIButton!
    @IBOutlet var lblStatus:UILabel!
    @IBOutlet var buttonAppHint:RoundButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.clipsToBounds = true
        self.objStackView.layer.cornerRadius = 10.0
        self.objStackView.clipsToBounds = true
        
        self.subContainerView.layer.cornerRadius = 10.0
        self.subContainerView.clipsToBounds = true
        self.buttonApp.imageView?.contentMode = .scaleAspectFit
        
        self.buttonAppHint.layer.borderWidth = 0.7
        self.buttonAppHint.layer.borderColor = kThemeColor.cgColor
        
        self.buttonChildCollapase.imageView?.contentMode = .scaleAspectFill
        self.buttonChild.imageView?.contentMode = .scaleAspectFill
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
