//
//  ParentLandingViewController.swift
//  TeenageSafety
//
//  Created by user on 19/11/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ParentLandingViewController: UIViewController {

    @IBOutlet var buttonLogin:RoundCornerButton!
    @IBOutlet var buttonSignUp:RoundCornerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUp()
    }
    

    // MARK: - Custom Methods
    func setUp(){
        self.buttonLogin.isBorder = true
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonLogInSelector(sender:UIButton){
        if let childViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentLoginViewConroller") as? ParentLoginViewConroller{
            self.navigationController?.pushViewController(childViewController, animated: true)
        }
    }
    @IBAction func buttonSignUpSelector(sender:UIButton){
        if let childViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentSignUpViewController") as? ParentSignUpViewController{
            self.navigationController?.pushViewController(childViewController, animated: true)
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}
