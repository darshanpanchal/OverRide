//
//  ParentSummaryCollectionViewCell.swift
//  TeenageSafety
//
//  Created by user on 09/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ParentSummaryCollectionViewCell: UICollectionViewCell {

    @IBOutlet var containerView:UIView!
    
    @IBOutlet var buttonChildImage:RoundButton!
    @IBOutlet var buttonVehicleDiagnostics:RoundCornerButton!
    @IBOutlet var buttonChildScore:UIButton!
    
    @IBOutlet var lblChildName:UILabel!
    @IBOutlet var lblChildScore:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.cornerRadius = 6.0
        self.containerView.clipsToBounds = true
        self.buttonChildScore.layer.borderWidth = 1.0
        self.buttonChildScore.layer.cornerRadius = 16.0
        self.buttonChildScore.clipsToBounds = true
//        self.addShadowOnContainerView()
    }
    func addShadowOnContainerView(){
        self.containerView.layoutIfNeeded()
        self.containerView.layer.shadowColor = UIColor.lightGray.cgColor
        self.containerView.layer.shadowOpacity = 0.5
        self.containerView.layer.shadowOffset = CGSize.zero
        self.containerView.layer.shadowRadius = 6.0
    }
    func configureCurrentChild(isSelected:Bool){
            if isSelected{
                self.lblChildName.textColor = UIColor.white
                self.lblChildScore.textColor = UIColor.white
                self.buttonChildScore.setTitleColor(UIColor.white, for: .normal)
                self.buttonChildScore.layer.borderColor = UIColor.white.cgColor
                self.buttonChildScore.setBackgroundColor(color: kThemeColor, forState: .normal)
                self.containerView.backgroundColor = kThemeColor
                self.buttonVehicleDiagnostics.setBackgroundColor(color: UIColor.white, forState: .normal)
                self.buttonVehicleDiagnostics.setTitleColor(UIColor.init(hexString: "#363636"), for: .normal)
                
            }else{
                self.lblChildName.textColor = UIColor.init(hexString: "#363636")
                self.lblChildScore.textColor =  UIColor.init(hexString: "#363636")
                self.buttonChildScore.setTitleColor(UIColor.init(hexString: "#363636"), for: .normal)
                self.buttonChildScore.layer.borderColor =  UIColor.init(hexString: "#363636").cgColor
                self.buttonChildScore.setBackgroundColor(color: .white, forState: .normal)
                self.containerView.backgroundColor = .white
                self.buttonVehicleDiagnostics.setTitleColor(UIColor.white, for: .normal)
                self.buttonVehicleDiagnostics.setBackgroundColor(color: kThemeColor, forState: .normal)
            }
    }
    

}
