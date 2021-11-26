//
//  ParentChangePasswordViewController.swift
//  TeenageSafety
//
//  Created by user on 06/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MaterialTextField

class ParentChangePasswordViewController: UIViewController {

    @IBOutlet var txtOldPassword:MFTextField!
    @IBOutlet var txtPassword:MFTextField!
    @IBOutlet var txtConfirmPassword:MFTextField!
    
    var objOldPassword:UIButton?
    var objPassword:UIButton?
    var objConfirmPassword:UIButton?
    
    var isOldPasswordShow:Bool = false
    var isPasswordShow:Bool = false
    var isConfirmPasswordShow:Bool = false
    
    var changePasswordParameters:[String:Any] = [:]
    
    var isForChild:Bool = false
    var currentChild:Child?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUp()
    }
    func setUp(){
        self.txtOldPassword.setUpWithPlaceHolder(strPlaceHolder: "Old Password", isWhite: true)
        self.txtPassword.setUpWithPlaceHolder(strPlaceHolder: "New Password", isWhite: true)
        self.txtConfirmPassword.setUpWithPlaceHolder(strPlaceHolder: "Confirm New Password", isWhite: true)
        self.configureOldTextField()
        self.configureNewTextField()
        self.configureConfirmTextField()
        self.txtOldPassword.delegate = self
        self.txtPassword.delegate = self
        self.txtConfirmPassword.delegate = self
        if self.isForChild{
            if let objChild = self.currentChild{
                self.changePasswordParameters["id"] = "\(objChild.childId)"
            }
        }else{
            self.changePasswordParameters = [:]
        }
        
    }
    func isValidChangePasswordUp()->Bool{
        guard "\(self.changePasswordParameters["current_password"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtOldPassword.invalideFieldWithError(strError: "Please enter valid current password")
            }
            return false
        }
        guard "\(self.changePasswordParameters["password"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtPassword.invalideFieldWithError(strError: "Please enter valid password")
            }
            return false
        }
        guard "\(self.changePasswordParameters["confirm_password"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtConfirmPassword.invalideFieldWithError(strError: "Please enter valid confirm password")
            }
            return false
        }
        guard "\(self.changePasswordParameters["confirm_password"] ?? "")" == "\(self.changePasswordParameters["password"] ?? "")"  else {
            DispatchQueue.main.async {
                self.txtConfirmPassword.invalideFieldWithError(strError: "Confirm password not match to password")
            }
            return false
        }
        return true
    }
    func configureOldTextField(){
        objOldPassword = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        objOldPassword!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        objOldPassword!.addTarget(self, action: #selector(buttonOldPasswordEyeSelector(sender:)), for: .touchUpInside)
        self.txtOldPassword.rightViewMode = .always
        self.txtOldPassword.rightView = objOldPassword
    }
    func configureNewTextField(){
        objPassword = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        objPassword!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        objPassword!.addTarget(self, action: #selector(buttonNewPasswordEyeSelector(sender:)), for: .touchUpInside)
        self.txtPassword.rightViewMode = .always
        self.txtPassword.rightView = objPassword
    }
    func configureConfirmTextField(){
        objConfirmPassword = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        objConfirmPassword!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        objConfirmPassword!.addTarget(self, action: #selector(buttonConfirmPasswordEyeSelector(sender:)), for: .touchUpInside)
        self.txtConfirmPassword.rightViewMode = .always
        self.txtConfirmPassword.rightView = objConfirmPassword
    }
    
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonOldPasswordEyeSelector(sender:UIButton){
        self.txtOldPassword.becomeFirstResponder()
        self.isOldPasswordShow = !self.isOldPasswordShow
        if let currentText = self.txtOldPassword.text{
            self.txtOldPassword.text = ""
            self.txtOldPassword.isSecureTextEntry = !self.isOldPasswordShow
            self.txtOldPassword.text = currentText
        }
        if self.isOldPasswordShow{
            objOldPassword!.setImage(UIImage.init(named: "ic_eye_on"), for: .normal)
        }else{
            objOldPassword!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        }
    }
    @IBAction func buttonNewPasswordEyeSelector(sender:UIButton){
        self.txtPassword.becomeFirstResponder()
        self.isPasswordShow = !self.isPasswordShow
        if let currentText = self.txtPassword.text{
            self.txtPassword.text = ""
            self.txtPassword.isSecureTextEntry = !self.isPasswordShow
            self.txtPassword.text = currentText
        }
        if self.isPasswordShow{
            objPassword!.setImage(UIImage.init(named: "ic_eye_on"), for: .normal)
        }else{
            objPassword!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        }
    }
    @IBAction func buttonConfirmPasswordEyeSelector(sender:UIButton){
        self.txtConfirmPassword.becomeFirstResponder()
        self.isConfirmPasswordShow = !self.isConfirmPasswordShow
        if let currentText = self.txtConfirmPassword.text{
            self.txtConfirmPassword.text = ""
            self.txtConfirmPassword.isSecureTextEntry = !self.isConfirmPasswordShow
            self.txtConfirmPassword.text = currentText
        }
        if self.isConfirmPasswordShow{
            objConfirmPassword!.setImage(UIImage.init(named: "ic_eye_on"), for: .normal)
        }else{
            objConfirmPassword!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        }
    }
    @IBAction func buttonChangePasswordSelector(sender:UIButton){
        if self.isValidChangePasswordUp(){
            self.requestForChangePasswordAPI()
        }
    }
    
    /*
     {
     "current_password":"test1234",
     "password":"test12345",
     "confirm_password":"test12345"
     }
     */
    // MARK: - API Request Methods
    func requestForChangePasswordAPI(){
        if self.isValidChangePasswordUp(){
           
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: (self.isForChild) ? kParentChildChangePassword : kParentChangePassword, parameter: self.changePasswordParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                
                if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                    DispatchQueue.main.async {
                        if let keyWindow = UIApplication.shared.keyWindow{
                            keyWindow.showToast(message: message, isBlack: false)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }) { (responseFail) in
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                if let objFail = responseFail as? [String:Any],let message:String = objFail["message"] as? String{
                    DispatchQueue.main.async {
                        self.view.showToast(message: message, isBlack: false)
                        //                        ShowToast.show(toatMessage: message)
                    }
                }
            }
        }
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
extension ParentChangePasswordViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        print(typpedString)
        guard !typpedString.isContainWhiteSpace() else{
            
            return false
        }
        if textField == self.txtOldPassword{
            self.txtOldPassword.validateField()
            self.changePasswordParameters["current_password"] = "\(typpedString)"
        }else if textField == self.txtPassword{
            self.txtPassword.validateField()
            self.changePasswordParameters["password"] = "\(typpedString)"
        }else if textField == self.txtConfirmPassword{
            self.txtConfirmPassword.validateField()
            self.changePasswordParameters["confirm_password"] = "\(typpedString)"
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
       
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.txtOldPassword{
            self.txtPassword.becomeFirstResponder()
        }else if textField == self.txtPassword{
            self.txtConfirmPassword.becomeFirstResponder()
        }else if textField == self.txtConfirmPassword{
           //request for change password
            
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtOldPassword{
            if let text = self.txtOldPassword.text{
                self.changePasswordParameters["current_password"] = text
            }else{
                self.changePasswordParameters["current_password"] = ""
            }
        }else if textField == self.txtPassword{
            if let text = self.txtPassword.text{
                self.changePasswordParameters["password"] = text
            }else{
                self.changePasswordParameters["password"] = ""
            }
        }else if textField == self.txtConfirmPassword{
            if let text = self.txtConfirmPassword.text{
                self.changePasswordParameters["confirm_password"] = text
            }else{
                self.changePasswordParameters["confirm_password"] = ""
            }
        }
    }
}
