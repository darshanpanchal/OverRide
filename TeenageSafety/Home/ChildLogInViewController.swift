//
//  ChildLogInViewController.swift
//  TeenageSafety
//
//  Created by user on 19/11/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MaterialTextField

class ChildLogInViewController: UIViewController {

    var userLogInParameters:[String:Any] = [:]
    var isPasswordShow:Bool = false
    
    @IBOutlet var txtEmail:MFTextField!
    @IBOutlet var txtPassword:MFTextField!
    
    
    @IBOutlet var txtTest:MFTextField!
    
    @IBOutlet var buttonEye:UIButton!
    
    let kDefaultEmail = "test@mail.com"//"childuser5@mailnator.com"
    let kDefaultPassword = "ips12345"//"test12345"
    
    var objButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUp()

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.txtEmail.resignFirstResponder()
            self.txtPassword.resignFirstResponder()
        }
    }
    // MARK: - Custom Methods
    func setUp(){
        self.txtPassword.isSecureTextEntry = true
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self
        self.txtEmail.setUpWithPlaceHolder(strPlaceHolder: "Email")
        self.txtPassword.setUpWithPlaceHolder(strPlaceHolder: "Password")
        self.configureTextField()
        if UIDevice.current.isSimulator{
            self.txtEmail.text = kDefaultEmail//"mohitmfinal@itpathsolutions.co.in"
            self.txtPassword.text = kDefaultPassword//"test1234"
            self.userLogInParameters["email"] = kDefaultEmail//"mohitmfinal@itpathsolutions.co.in"
            self.userLogInParameters["password"] = kDefaultPassword//"test1234"
        }
    }
    func configureTextField(){
        objButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        objButton!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        objButton!.addTarget(self, action: #selector(buttonPasswordEyeSelector(sender:)), for: .touchUpInside)
        self.txtPassword.rightViewMode = .always
        self.txtPassword.rightView = objButton
        
    }
    func invalidTextField(){
       let obj = NSError.init(domain: "OverRide", code: 100, userInfo: [NSLocalizedDescriptionKey:"Test"])
        DispatchQueue.main.async {
            self.txtTest.setError(obj, animated: true)
            self.txtTest.setError(obj, animated: true)
        }
       
    }
    func validateTextField(){
        self.txtTest.setError(nil, animated: true)
    }
    func isValidLogIn()->Bool{
        guard "\(self.userLogInParameters["email"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        if let emailText:String = self.userLogInParameters["email"] as? String,!emailText.isValidEmail(){
            DispatchQueue.main.async {
                self.txtEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        
        guard "\(self.userLogInParameters["password"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtPassword.invalideFieldWithError(strError: "Please enter valid password.")
            }
            return false
        }
        
        self.txtEmail.validateField()
        self.txtPassword.validateField()
        
        return true
    }
    
    // MARK: - API Request
    func userLogInRequest(){
        
        if self.isValidLogIn(){
            
            
           
            
            
            self.userLogInParameters["device_type"] = "ios"
            if let deviceToken = UserDefaults.standard.object(forKey: "currentDeviceToken") as? String{
                self.userLogInParameters["device_token"] = deviceToken
            }else{
                self.userLogInParameters["device_token"] = "ios"
            }
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kChildLogIn, parameter: self.userLogInParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                
                if let objSuccess = responseSuccess as? [String:Any],let successData = objSuccess["data"] as? [String:Any]{
                    DispatchQueue.main.async {

                         self.pushToChildIntroScreen()
                        /*
                        if Child.isChildLoggedIn{
                            self.pushToChildHomeController()
                        }else{
                            self.pushToChildIntroScreen()
                        }*/
                        defer{
                            let objChild = Child.init(userDetail: successData)
                            objChild.setchildDetailToUserDefault()
                        }
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
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonPasswordEyeSelector(sender:UIButton){
        self.txtPassword.becomeFirstResponder()
        self.isPasswordShow = !self.isPasswordShow
        if let currentText = self.txtPassword.text{
            self.txtPassword.text = ""
            self.txtPassword.isSecureTextEntry = !self.isPasswordShow
            self.txtPassword.text = currentText
        }
        if self.isPasswordShow{
            self.objButton!.setImage(UIImage.init(named: "ic_eye_on"), for: .normal)
        }else{
            self.objButton!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        }
    }
    @IBAction func buttonLogInSelector(sender:UIButton){
        
        self.userLogInRequest()
    }
    @IBAction func buttonContainerViewSelection(sender:UIButton){
        self.view.endEditing(true)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToChildIntroScreen(){
        let objChildIntro = UIStoryboard.init(name: "ChildIntroduction", bundle: nil)
        if let childIntroViewController = objChildIntro.instantiateViewController(withIdentifier: "ChildIntroViewController") as? ChildIntroViewController{
            self.navigationController?.pushViewController(childIntroViewController, animated: true)
        }
    }
    func pushToChildHomeController(){
        
        if let objTabController = self.storyboard?.instantiateViewController(withIdentifier: "ChildTabBarViewController") as? ChildTabBarViewController{
            objTabController.selectedIndex = 0
            self.navigationController?.pushViewController(objTabController, animated: false)
            
        }
    }
    func pushToChildOBDConnectionViewController(){
        if let objObdConnectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildConnectODBViewController") as? ChildConnectODBViewController{
            self.navigationController?.pushViewController(objObdConnectionViewController, animated: true)
        }
    }
  

}
extension ChildLogInViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        
        if textField == self.txtEmail{
            self.txtEmail.validateField()
            self.userLogInParameters["email"] = "\(typpedString)"
        }else{
            self.txtPassword.validateField()
            self.userLogInParameters["password"] = "\(typpedString)"
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.txtEmail{
            self.userLogInParameters["email"] = ""
        }else{
            self.userLogInParameters["password"] = ""
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.txtEmail{
            self.txtPassword.becomeFirstResponder()
        }else{
            self.userLogInRequest()
        }
        return true
    }
}
extension UITextField {
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension MFTextField{
    func setUpWithPlaceHolder(strPlaceHolder:String,isWhite:Bool = true){
        if isWhite{
            self.errorColor = UIColor.white
            self.tintColor = UIColor.white
            self.textColor = UIColor.white
            self.placeholderColor = UIColor.white
            self.defaultPlaceholderColor = UIColor.white
        }else{
            self.errorColor = UIColor.black
            self.tintColor = UIColor.black
            self.textColor = UIColor.black
            self.placeholderColor = UIColor.darkGray
            self.defaultPlaceholderColor = UIColor.darkGray
        }
        let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 18.0)! ]
        self.attributedPlaceholder = NSAttributedString(string: strPlaceHolder, attributes: myAttribute)
        self.font = UIFont(name: "Poppins-Regular", size: 18.0)!
    }
    
    func invalideFieldWithError(strError:String){
        let obj = NSError.init(domain: "OverRide", code: 100, userInfo: [NSLocalizedDescriptionKey:strError])
        DispatchQueue.main.async {
            self.setError(obj, animated: true)
            self.setError(obj, animated: true)
        }
    }
    func validateField(){
        self.setError(nil, animated: true)
    }
}
