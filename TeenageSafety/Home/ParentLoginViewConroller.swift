//
//  ParentLoginViewConroller.swift
//  TeenageSafety
//
//  Created by IPS on 21/11/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MaterialTextField

class ParentLoginViewConroller: UIViewController {
    
    var userParentLogInParameters:[String:Any] = [:]
    @IBOutlet var txtParentEmail:MFTextField!
    @IBOutlet var txtParentPassword:MFTextField!
    
    
    var objButton:UIButton?
    
    var isPasswordShow:Bool = false
    
    
    let kDefaultEmail = "darshanp@itpathsolutions.in"
    let kDefaultPassword = "test12345"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUp()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.txtParentEmail.resignFirstResponder()
            self.txtParentPassword.resignFirstResponder()
        }
    }
    func setUp(){
        self.txtParentEmail.delegate = self
        self.txtParentPassword.delegate = self
        self.txtParentEmail.setUpWithPlaceHolder(strPlaceHolder: "Email")
        self.txtParentPassword.setUpWithPlaceHolder(strPlaceHolder: "Password")
        self.configureTextField()
        self.txtParentPassword.isSecureTextEntry = true
        
        guard let currentDeviceUUID = UIDevice.current.identifierForVendor else {
            return
        }
        
        if UIDevice.current.isSimulator || "\(currentDeviceUUID)" == "13B4B0FE-1B79-4C4C-B32F-4EC41F593213"{ //unique for IPS iPhone X only for this application
            self.txtParentEmail.text = kDefaultEmail//"mohitmfinal@itpathsolutions.co.in"
            self.txtParentPassword.text = kDefaultPassword//"test1234"
            self.userParentLogInParameters["email"] = kDefaultEmail//"mohitmfinal@itpathsolutions.co.in"
            self.userParentLogInParameters["password"] = kDefaultPassword//"test1234"
        }
    }
    func configureTextField(){
        objButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        objButton!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        objButton!.addTarget(self, action: #selector(buttonPasswordEyeSelector(sender:)), for: .touchUpInside)
        self.txtParentPassword.rightViewMode = .always
        self.txtParentPassword.rightView = objButton
    }
    func isValidLogIn()->Bool{
        
        guard "\(self.userParentLogInParameters["email"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtParentEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        if let emailText:String = self.userParentLogInParameters["email"] as? String,!emailText.isValidEmail(){
            DispatchQueue.main.async {
                self.txtParentEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        
        guard "\(self.userParentLogInParameters["password"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtParentPassword.invalideFieldWithError(strError: "Please enter valid password")
            }
            return false
        }
        
        self.txtParentEmail.validField()
        self.txtParentPassword.validField()
        
        return true
    }
    // MARK: - API Request
    func userParentLogInRequest(){
        if self.isValidLogIn(){
            self.userParentLogInParameters["device_type"] = "ios"
            self.userParentLogInParameters["device_id"] = "\(UIDevice.current.identifierForVendor!.uuidString)"
            if let deviceToken = UserDefaults.standard.object(forKey: "currentDeviceToken") as? String{
                self.userParentLogInParameters["device_token"] = deviceToken
            }else{
                self.userParentLogInParameters["device_token"] = "iOS"
            }
            
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentLogin, parameter: self.userParentLogInParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [String:Any]{
                    let objParent = Parent.init(userDetail: successData)
                    objParent.setParentDetailToUserDefault()
                    DispatchQueue.main.async {
                        self.view.showToast(message: message, isBlack: false)
                        self.pushToParentHomeController()
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
    // MARK: - Button Action
    @IBAction func buttonLogInSelector(sender:UIButton){
        self.userParentLogInRequest()
    }
    @IBAction func buttonBackSelector(sender:UIButton){
         self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonPasswordEyeSelector(sender:UIButton){
        self.txtParentPassword.becomeFirstResponder()
        self.isPasswordShow = !self.isPasswordShow
        if let currentText = self.txtParentPassword.text{
            self.txtParentPassword.text = ""
            self.txtParentPassword.isSecureTextEntry = !self.isPasswordShow
            self.txtParentPassword.text = currentText
        }
        if self.isPasswordShow{
            objButton!.setImage(UIImage.init(named: "ic_eye_on"), for: .normal)
        }else{
            objButton!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        }
    }
    @IBAction func buttonForegetPasswordSelector(sender:UIButton){
        if let childViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as? ForgotPasswordViewController{
            self.navigationController?.pushViewController(childViewController, animated: true)
        }
    }
    @IBAction func buttonChildLogInSelector(sender:UIButton){
        if let childViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildLogInViewController") as? ChildLogInViewController{
            self.navigationController?.pushViewController(childViewController, animated: true)
        }
    }
    @IBAction func buttonParentSignUpSelector(sender:UIButton){
        if let childViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentSignUpViewController") as? ParentSignUpViewController{
            self.navigationController?.pushViewController(childViewController, animated: true)
        }
    }
    @IBAction func buttonContainerViewSelection(sender:UIButton){
        self.view.endEditing(true)
    }
    // MARK: - Navigation
    func pushToParentHomeController(){
        if let objTabController = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as? HomeTabBarViewController{
            objTabController.selectedIndex = 0
            self.navigationController?.pushViewController(objTabController, animated: false)
        }
        /*
        if let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController{
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }*/
    }
}
extension ParentLoginViewConroller:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        if textField == self.txtParentEmail{
            self.txtParentEmail.validateField()
            self.userParentLogInParameters["email"] = "\(typpedString)"
        }else{
            self.txtParentPassword.validateField()
            self.userParentLogInParameters["password"] = "\(typpedString)"
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.txtParentEmail{
            self.userParentLogInParameters["email"] = ""
        }else{
            self.userParentLogInParameters["password"] = ""
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.txtParentEmail{
            self.txtParentPassword.becomeFirstResponder()
        }else{
            self.userParentLogInRequest()
        }
        return true
    }
}
extension UIDevice {
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
