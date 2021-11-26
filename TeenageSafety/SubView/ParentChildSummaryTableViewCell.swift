//
//  ParentChildSummaryTableViewCell.swift
//  TeenageSafety
//
//  Created by user on 09/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ParentChildSummaryTableViewCell: UITableViewCell {

    
    @IBOutlet var lblDay:UILabel!
    @IBOutlet var lblDate:UILabel!
    @IBOutlet var lblPercentage:UILabel!
    @IBOutlet var lblDriveGrade:UILabel!
    @IBOutlet var lblOverSpeedCount:UILabel!
    @IBOutlet var lblHarshBreakCount:UILabel!
    @IBOutlet var lblRapidCount:UILabel!
    @IBOutlet var lblIdealCount:UILabel!
    
    @IBOutlet var lblGrade:UILabel!
    
    @IBOutlet var buttonGrade:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.buttonGrade.clipsToBounds = true
        self.buttonGrade.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
