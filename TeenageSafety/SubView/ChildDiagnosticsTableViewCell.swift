//
//  ChildDiagnosticsTableViewCell.swift
//  TeenageSafety
//
//  Created by user on 20/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ChildDiagnosticsTableViewCell: UITableViewCell {

    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var lblDetail:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
