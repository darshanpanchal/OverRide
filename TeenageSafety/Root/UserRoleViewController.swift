//
//  UserRoleViewController.swift
//  TeenageSafety
//
//  Created by user on 19/11/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import Toast_Swift

class UserRoleViewController: UIViewController {

    
    @IBOutlet var lblParent:UILabel!
    
    @IBOutlet var lblChild:UILabel!
    
    @IBOutlet var buttonContinue:UIButton!
    
    @IBOutlet var imgTickParent:UIImageView!
    
    @IBOutlet var imgTickChild:UIImageView!
    
    private var isforparent:Bool = true
    
    var isParent:Bool{
        get{
            return isforparent
        }
        set{
            self.isforparent = newValue
            //Configure User Role
            DispatchQueue.main.async {
                if self.isParent{
                    self.imgTickParent.isHidden = false
                    self.imgTickChild.isHidden = true
                }else{
                    self.imgTickParent.isHidden = true
                    self.imgTickChild.isHidden = false
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup()
        /*
        if Parent.isParentLoggedIn{
            self.pushToMapViewScreenController()
        }else if Child.isChildLoggedIn{
            self.pushToChildHomeController()
        }*/
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    // MARK: - Custom Methods
    func setup(){
        self.imgTickParent.isHidden = true
        self.imgTickChild.isHidden = true
        self.buttonContinue.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonChildSelector(sender:UIButton){
      
        
        
        self.buttonContinue.isHidden = false
        self.isParent = false
    }
    @IBAction func buttonParentSelector(sender:UIButton){
        self.buttonContinue.isHidden = false
        self.isParent = true
    }
    @IBAction func buttonContinueSelector(sender:UIButton){
        if self.isParent{//push to parent landing
            self.pushToParentLandingScreenController()
        }else{//push to child login
            self.pushToChildViewController()
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToChildViewController(){
        if let childViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildLogInViewController") as? ChildLogInViewController{
            self.navigationController?.pushViewController(childViewController, animated: true)
        }
    }
    func pushToParentLandingScreenController(){
        if let parentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentLandingViewController") as? ParentLandingViewController{
            self.navigationController?.pushViewController(parentViewController, animated: true)
        }
    }
    func pushToMapViewScreenController(){
        if let objTabController = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as? HomeTabBarViewController{
            objTabController.selectedIndex = 0
            self.navigationController?.pushViewController(objTabController, animated: false)
        }
    }
    func pushToChildHomeController(){
        if let objTabController = self.storyboard?.instantiateViewController(withIdentifier: "ChildTabBarViewController") as? ChildTabBarViewController{
            objTabController.selectedIndex = 0
            self.navigationController?.pushViewController(objTabController, animated: false)
        }
    }

}
extension UIView{
    func showToast(message:String,isBlack:Bool){
        var imageName = "splash.png"
        var objStyle = ToastManager.shared.style
        if isBlack{
            objStyle.backgroundColor = UIColor.black
            objStyle.shadowColor = UIColor.white
            objStyle.messageColor = UIColor.white
            objStyle.titleColor = UIColor.white
            imageName = "splash_white.png"
        }else{
            objStyle.backgroundColor = UIColor.white
            objStyle.shadowColor = UIColor.init(hexString: "#363636")
            objStyle.messageColor = UIColor.init(hexString: "#363636")
            objStyle.titleColor = UIColor.init(hexString: "#363636")
            
        }
        objStyle.cornerRadius = 30.0
        objStyle.imageSize = CGSize.init(width: 50.0, height: 50.0)
        objStyle.activitySize = CGSize.init(width: 300.0, height: 40.0)
        self.makeToast(message, duration: 2.5, position: .bottom, title:"", image: UIImage(named: imageName) , style: objStyle, completion: nil)
    }
}
