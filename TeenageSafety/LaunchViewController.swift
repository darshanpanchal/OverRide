//
//  LaunchViewController.swift
//  TeenageSafety
//
//  Created by user on 13/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            if Parent.isParentLoggedIn{
                self.pushToMapViewScreenController()
            }else if Child.isChildLoggedIn,let currentChild = Child.getChildFromUserDefault(){
                self.apiReqestForBLEOnCofiguration(childID: currentChild.childId)
                self.pushToChildHomeController()
            }else{
                self.performSegue(withIdentifier: "showHome", sender: nil)
            }
            
        }
    }
    // MARK: - API Request methods
    func apiReqestForBLEOnCofiguration(childID:String){
        var mdmParameter:[String:Any] = [:]
        mdmParameter["id"] = childID
        mdmParameter["request_type"] = "Settings"
        var setting:[String:Any] = [:]
        setting["item"] = "Bluetooth"
        setting["enabled"] = true
        mdmParameter["Settings"] = [setting]
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:"mdm/command", parameter: mdmParameter as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                print(responseSuccess)
            }) { (responseFail) in
                print(responseFail)
            }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToMapViewScreenController(){
        
        let objNavigationController = UINavigationController.init(rootViewController: self)
        if let userRoleViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserRoleViewController") as? UserRoleViewController{
            objNavigationController.isNavigationBarHidden = true
            objNavigationController.pushViewController(userRoleViewController, animated: false)
            if let objTabController = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as? HomeTabBarViewController{
                objTabController.selectedIndex = 0
                objNavigationController.pushViewController(objTabController, animated: false)
                if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
                           keyWindow.rootViewController = objNavigationController
                           keyWindow.makeKeyAndVisible()
                }
            }
        }
    }
    func pushToChildHomeController(){
        let objNavigationController = UINavigationController.init(rootViewController: self)
        if let userRoleViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserRoleViewController") as? UserRoleViewController{
            objNavigationController.isNavigationBarHidden = true
            objNavigationController.pushViewController(userRoleViewController, animated: false)
            if let objTabController = self.storyboard?.instantiateViewController(withIdentifier: "ChildTabBarViewController") as? ChildTabBarViewController{
                objTabController.selectedIndex = 0
                objNavigationController.pushViewController(objTabController, animated: false)
                if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
                           keyWindow.rootViewController = objNavigationController
                           keyWindow.makeKeyAndVisible()
                }
            }
        }
    }
}
