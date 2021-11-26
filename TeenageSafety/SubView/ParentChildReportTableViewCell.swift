//
//  ParentChildReportTableViewCell.swift
//  TeenageSafety
//
//  Created by user on 26/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ParentChildReportTableViewCell: UITableViewCell {

    @IBOutlet var buttonGrade:UIButton!
    @IBOutlet var lblTripCount:UILabel!
    
    @IBOutlet var lblPercentage:UILabel!
    @IBOutlet var lblDriveGrade:UILabel!
    @IBOutlet var lblPerformanceType:UILabel!
    @IBOutlet var lblFromLocation:UILabel!
    @IBOutlet var lblFromTime:UILabel!
    @IBOutlet var lblToLocation:UILabel!
    @IBOutlet var lblToTime:UILabel!
    @IBOutlet var lblTopSpeed:UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.buttonGrade.clipsToBounds = true
        self.buttonGrade.layer.cornerRadius = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
