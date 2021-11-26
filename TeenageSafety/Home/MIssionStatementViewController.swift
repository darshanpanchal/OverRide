//
//  MIssionStatementViewController.swift
//  TeenageSafety
//
//  Created by user on 19/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class MIssionStatementViewController: UIViewController {

    @IBOutlet var containerView:UIView!
    @IBOutlet var buttonClose:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //initial setup
        self.setup()
    }
    // MARK: - Setup Methods
    func setup(){
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10.0
    }

    // MARK: - Selector Methods
    @IBAction func buttonCloseSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
   

}
