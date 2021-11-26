//
//  ForgotPasswordViewController.swift
//  TeenageSafety
//
//  Created by IPS on 21/11/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MaterialTextField

class ForgotPasswordViewController: UIViewController {
 
    var userForgetPasswordParameters:[String:Any] = [:]
    
    @IBOutlet var txtEmail:MFTextField!
    
    let kDefaultEmail = "darshanp@itpathsolutions.in"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUp()
    }
    // MARK: - Custom Methods
    func setUp(){
        self.txtEmail.delegate = self
        self.txtEmail.setUpWithPlaceHolder(strPlaceHolder: "Email")
        
        guard let currentDeviceUUID = UIDevice.current.identifierForVendor else {
                  return
        }
        
        if UIDevice.current.isSimulator || "\(currentDeviceUUID)" == "13B4B0FE-1B79-4C4C-B32F-4EC41F593213"{
            self.txtEmail.text = kDefaultEmail//"mohitmfinal@itpathsolutions.co.in"
            self.userForgetPasswordParameters["email"] = kDefaultEmail//"mohitmfinal@itpathsolutions.co.in"
        }

    }
    func isValidLogIn()->Bool{
        
        guard "\(self.userForgetPasswordParameters["email"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        if let emailText:String = self.userForgetPasswordParameters["email"] as? String,!emailText.isValidEmail(){
            DispatchQueue.main.async {
                self.txtEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        self.txtEmail.validField()
         return true
    }
    func userForfetPasswordRequest(){
        if self.isValidLogIn(){

            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentForgotPassword, parameter: self.userForgetPasswordParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let objSuccess = responseSuccess as? [String:Any]{
                    if let message = objSuccess["message"] as? String{
                        DispatchQueue.main.async {
                            if let keyWindow = UIApplication.shared.keyWindow{
                                keyWindow.showToast(message: message, isBlack: false)
                            }
                            
                        }
                    }
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }) { (responseFail) in
                if let objFail = responseFail as? [String:Any],let message:String = objFail["message"] as? String{
                    print(objFail)
                    DispatchQueue.main.async {
                        self.view.showToast(message: message, isBlack: false)
                    }
                }
            }
        }
    }
    // MARK: - Button Action
    @IBAction func buttonForegetPasswordSelector(sender:UIButton){
        
        self.userForfetPasswordRequest()
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonContainerViewSelection(sender:UIButton){
        self.view.endEditing(true)
    }
    
}
extension ForgotPasswordViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        if textField == self.txtEmail{
            self.txtEmail.validateField()
            self.userForgetPasswordParameters["email"] = "\(typpedString)"
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.txtEmail{
            self.userForgetPasswordParameters["email"] = ""
        }
        return true
    }
   
}
