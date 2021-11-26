//
//  ChildProfileViewController.swift
//  TeenageSafety
//
//  Created by user on 16/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import SDWebImage
import MaterialTextField

class ChildProfileViewController: UIViewController {

    @IBOutlet var buttonProfile:RoundButton!
    @IBOutlet var lblName:UILabel!
    
    @IBOutlet var txtDOB:MFTextField!
    @IBOutlet var txtEmail:MFTextField!
    @IBOutlet var txtPhoneNumber:MFTextField!
    
    var currentChild:Child?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //intial setup
        self.setup()
        
        
    }
    // MARK: - Custom Methods
    func setup(){
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //GET Child Profile API
        self.getChildProfileAPI()
    }
    func configureCurrentUser(){
        if let objChild:Child = Child.getChildFromUserDefault(){
            self.currentChild = objChild
            let objURL = URL.init(string: objChild.childImage)
            self.buttonProfile.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: nil)
            self.buttonProfile.imageView?.contentMode = .scaleAspectFill
            
            DispatchQueue.main.async {
                self.lblName.text = objChild.childName
                self.txtEmail.text = objChild.childEmail
                self.txtDOB.text = objChild.childDOB
                self.txtPhoneNumber.text = "(\(objChild.childCountryCode))  \(objChild.childPhone)"
                self.txtEmail.isEnabled = false
                self.txtDOB.isEnabled = false
                self.txtPhoneNumber.isEnabled = false
            }
        }
    }
    // MARK: - API Methods
    func getChildProfileAPI(){
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: kChildGETProfile, parameter:nil, isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [String:Any]{
                let objChild =  Child.init(userDetail: successData, isUpdateProfile: true) 
                objChild.setchildDetailToUserDefault()
                
                DispatchQueue.main.async {
                    self.configureCurrentUser()
                    //self.view.showToast(message: message, isBlack: false)
                }
            }
        }) { (responseFail) in
            DispatchQueue.main.async {
                print(responseFail)
                ProgressHud.hide()
            }
            if let objFail = responseFail as? [String:Any],let message:String = objFail["message"] as? String{
                DispatchQueue.main.async {
                    self.view.showToast(message: message, isBlack: true)
                    //ShowToast.show(toatMessage: message)
                }
            }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.popToBackViewController()
        }
        
    }
    @IBAction func buttonEditProfileSelector(sender:UIButton){
        if let _ = self.currentChild{
            self.pushToParentEditChildViewController(currentChid: self.currentChild!)
        }
        
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func popToBackViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    func pushToParentEditChildViewController(currentChid:Child){
        if let objParentEditChildViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentEditChildViewController") as? ParentEditChildViewController{
            objParentEditChildViewController.currentChild = currentChid
            objParentEditChildViewController.isForChild = true
            self.navigationController?.pushViewController(objParentEditChildViewController, animated: true)
        }
    }

}
