//
//  MaterialShowCaseViewController.swift
//  TeenageSafety
//
//  Created by user on 13/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MaterialShowcase

protocol MaterialDelegate{
    func addChildSelector()
}
class MaterialShowCaseViewController: UIViewController {

    @IBOutlet var buttonAddChild:RoundButton!
    @IBOutlet var bottomContaint:NSLayoutConstraint!
    
    var objDelegate:MaterialDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kUserDefault.setValue("true", forKey: kShowCaseForAddChild)
        
        self.bottomContaint.constant =  49.0 + 20.0
        
        self.buttonAddChild.imageView?.contentMode = .scaleAspectFit
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.displayShowCase()

    }
    
    func displayShowCase() {
        self.view.layoutIfNeeded()
        let showcase = MaterialShowcase()
        showcase.targetHolderRadius = 35.0
        showcase.setTargetView(view: self.buttonAddChild)
        showcase.backgroundViewType = .full
        showcase.primaryText = ""
        showcase.primaryTextFont = UIFont.init(name:"Avenir-Heavy", size: 30.0)//CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        showcase.secondaryText = ""
        showcase.secondaryTextFont = UIFont.init(name:"Avenir-Heavy", size: 20.0)
        showcase.delegate = self
        showcase.shouldSetTintColor = true // It should be set to false when button uses image.
        showcase.backgroundPromptColor = .clear//UIColor.black.withAlphaComponent(0.1)
        showcase.backgroundPromptColorAlpha = 0.0
        showcase.isTapRecognizerForTargetView = true
        showcase.show(completion: {
        })
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonAddChildSelector(sender:UIButton){
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension MaterialShowCaseViewController: MaterialShowcaseDelegate {
    func showCaseWillDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        //kUserDefault.set(true, forKey: kShowCaseForLocationButton)
    }
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        self.dismiss(animated: false, completion: nil)
        if let _ = self.objDelegate{
            self.objDelegate!.addChildSelector()
        }
    }
}
