//
//  ParentEditChildViewController.swift
//  TeenageSafety
//
//  Created by user on 05/12/19.
//  Copyright © 2019 user. All rights reserved.
//


import UIKit
import MobileCoreServices
import MaterialTextField

class ParentEditChildViewController: UIViewController {
    
    
    @IBOutlet var imageChildName:UIImageView!
    @IBOutlet var imageDateOfBirth:UIImageView!
    @IBOutlet var imageEmail:UIImageView!
    @IBOutlet var imagePassword:UIImageView!
    @IBOutlet var imageConfirmPassword:UIImageView!
    @IBOutlet var imagePhone:UIImageView!
    @IBOutlet var imagePhoneDrop:UIImageView!
    
    
    var currentChild:Child?
    
    
    @IBOutlet weak var tblParentSignup:UITableView!
    @IBOutlet var lblTermsAndCondition:UILabel!
    
    @IBOutlet var buttonCountryCode:UIButton!
    
    @IBOutlet var buttonSignUp:UIButton!
    
    @IBOutlet var buttonCamera:UIButton!
    @IBOutlet var buttonParentImage:RoundButton!
    
    @IBOutlet var txtDisplayName:MFTextField!
    @IBOutlet var txtDateOfBirth:MFTextField!
    @IBOutlet var txtEmail:MFTextField!
    @IBOutlet var txtPassword:MFTextField!
    @IBOutlet var txtConfirmPassword:MFTextField!
    @IBOutlet var txtPhoneNumber:MFTextField!
    
    @IBOutlet var imgCheckBox:UIImageView!
    
    @IBOutlet var containerTermsAndConditions:UIView!
    
    @IBOutlet var buttonBoy:UIButton!
    @IBOutlet var buttonGirl:UIButton!
    
    
    @IBOutlet var imageCamera:UIImageView!
    
    var fromDatePicker:UIDatePicker = UIDatePicker()
    var fromDatePickerToolbar:UIToolbar = UIToolbar()
    
    var userProfileImage:UIImage?
    
    var isPasswordShow:Bool = false
    var isConfirmPasswordShow:Bool = false
    
    var objPassword:UIButton?
    var objConfirmPassword:UIButton?
    
    var isForChild:Bool = false
    
    var isBoySelected:Bool = true{
        didSet{
            DispatchQueue.main.async {
                self.configureSelectedGender()
            }
            
        }
    }
    lazy var objImagePickerController = UIImagePickerController()
    private var countryCode:String = "+1"
    var selectedCountryCode:String{
        get{
            return countryCode
        }
        set{
            countryCode = newValue.removeWhiteSpaces()
            DispatchQueue.main.async {
                //Update Selected Country Code
                self.updateSelectedCountryCode()
            }
        }
    }
    private var isterms:Bool = false
    var istermsAccepted:Bool{
        get{
            return isterms
        }
        set{
            self.isterms = newValue
            DispatchQueue.main.async {
                //UpdateTerms and Conditions
                self.updateTermsAndConditioins()
            }
        }
    }
    
    let text = "I agree to the Terms and Conditions."
    let termsConditionsURL = "https://www.google.com"
    
    
    var userfieldsName = ["Child Name","Email","Password","Confirm Password","Phone No"]
    
    var updateParentChildParameters:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setUp()
        
    }
    //MARK: - SetUp Methods
    func setUp(){
        self.txtDisplayName.setUpWithPlaceHolder(strPlaceHolder: "Child Name",isWhite: false)
        self.txtDateOfBirth.setUpWithPlaceHolder(strPlaceHolder: "Date Of Birth",isWhite: false)
        self.txtEmail.setUpWithPlaceHolder(strPlaceHolder: "Email",isWhite: false)
        self.txtPassword.setUpWithPlaceHolder(strPlaceHolder: "Password",isWhite: false)
        self.txtConfirmPassword.setUpWithPlaceHolder(strPlaceHolder: "Confirm Password",isWhite: false)
        self.txtPhoneNumber.setUpWithPlaceHolder(strPlaceHolder: "Phone Number",isWhite: false)
        self.configurePasswordTextField()
        self.configureConfirmPasswordTextField()
        self.buttonParentImage.imageView?.contentMode = .scaleAspectFill
        
        self.updateParentChildParameters["country_code"] = "1"
        
        self.txtDisplayName.delegate = self
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self
        self.txtConfirmPassword.delegate = self
        self.txtPhoneNumber.delegate = self
        
        self.configureImagesTint()
        
        self.configureFormDatePicker()
        self.isBoySelected = true
        
        self.buttonBoy.imageView?.contentMode = .scaleAspectFit
        self.buttonGirl.imageView?.contentMode = .scaleAspectFit
        self.configureCurrentUser()
        
        self.imageCamera.clipsToBounds = true
        self.imageCamera.layer.cornerRadius = 15.0
        self.imageCamera.layer.borderWidth = 2.5
        self.imageCamera.layer.borderColor = UIColor.white.cgColor
        
    }
    func configureCurrentUser(){
        if let objParent:Child = self.currentChild{
            
             let objURL = URL.init(string: objParent.childImage)
            self.buttonParentImage.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: { (image, error, type, url)  in
                if let _ = image{
                    self.userProfileImage = image!
                }
            })

            self.buttonParentImage.imageView?.contentMode = .scaleAspectFill
            
            
            DispatchQueue.main.async {
                self.updateParentChildParameters["id"] = objParent.childId
                self.txtDisplayName.text = objParent.childName
                self.updateParentChildParameters["name"] = objParent.childName
                self.txtEmail.text = objParent.childEmail
                self.updateParentChildParameters["email"] = objParent.childEmail
                self.buttonCountryCode.setTitle("\(objParent.childCountryCode)", for: .normal)
                self.updateParentChildParameters["country_code"] = objParent.childCountryCode
                self.txtPhoneNumber.text = "\(objParent.childPhone)"
                self.updateParentChildParameters["phone"] = objParent.childPhone
                self.updateParentChildParameters["gender"] = objParent.childGender
                self.isBoySelected = (objParent.childGender == "male")
                self.txtDateOfBirth.text = objParent.childDOB
                self.updateParentChildParameters["dob"] = objParent.childDOB
            }
        }
    }
    func configureImagesTint(){
        self.imageChildName.image = UIImage.init(named: "username")?.withRenderingMode(.alwaysTemplate)
        self.imageDateOfBirth.image = UIImage.init(named: "calendar")?.withRenderingMode(.alwaysTemplate)
        self.imageEmail.image = UIImage.init(named: "email")?.withRenderingMode(.alwaysTemplate)
        self.imagePassword.image = UIImage.init(named: "lock")?.withRenderingMode(.alwaysTemplate)
        self.imageConfirmPassword.image = UIImage.init(named: "lock")?.withRenderingMode(.alwaysTemplate)
        self.imagePhone.image = UIImage.init(named: "telephone")?.withRenderingMode(.alwaysTemplate)
        self.imagePhoneDrop.image = UIImage.init(named: "down")?.withRenderingMode(.alwaysTemplate)
    }
    func configureFormDatePicker(){
        
        self.fromDatePickerToolbar.sizeToFit()
        self.fromDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.fromDatePickerToolbar.layer.borderWidth = 1.0
        self.fromDatePickerToolbar.clipsToBounds = true
        self.fromDatePickerToolbar.backgroundColor = UIColor.white
        self.fromDatePicker.datePickerMode = .date
        self.fromDatePicker.set18YearValidation()
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ParentEditChildViewController.doneFormDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"Date Of Birth"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ParentEditChildViewController.cancelFormDatePicker))
        self.fromDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtDateOfBirth.inputView = self.fromDatePicker
        self.txtDateOfBirth.inputAccessoryView = self.fromDatePickerToolbar
    }
    @objc func doneFormDatePicker(){
        DispatchQueue.main.async {
            self.txtDateOfBirth.resignFirstResponder()
        }
        self.txtDateOfBirth.text = "\(self.fromDatePicker.date.yyyyMMdd)"
        self.updateParentChildParameters["dob"] = "\(self.fromDatePicker.date.yyyyMMdd)"
        self.txtDateOfBirth.validateField()
    }
    @objc func cancelFormDatePicker(){
        DispatchQueue.main.async {
            self.txtDateOfBirth.resignFirstResponder()
        }
    }
    func configureSelectedGender(){
        if self.isBoySelected{
            self.buttonBoy.imageView?.image = #imageLiteral(resourceName: "round_select")
            self.buttonGirl.imageView?.image = #imageLiteral(resourceName: "round_deselect")
        }else{
            self.buttonBoy.imageView?.image = #imageLiteral(resourceName: "round_deselect")
            self.buttonGirl.imageView?.image = #imageLiteral(resourceName: "round_select")
        }
    }
    func configurePasswordTextField(){
        self.txtPassword.isSecureTextEntry = true
        objPassword = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        objPassword!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        objPassword!.addTarget(self, action: #selector(buttonPasswordEyeSelector(sender:)), for: .touchUpInside)
        self.txtPassword.rightViewMode = .always
        self.txtPassword.rightView = objPassword
    }
    func configureConfirmPasswordTextField(){
        self.txtConfirmPassword.isSecureTextEntry = true
        objConfirmPassword = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        objConfirmPassword!.setImage(UIImage.init(named: "ic_eye_off"), for: .normal)
        objConfirmPassword!.addTarget(self, action: #selector(buttonConfirmPasswordEyeSelector(sender:)), for: .touchUpInside)
        self.txtConfirmPassword.rightViewMode = .always
        self.txtConfirmPassword.rightView = objConfirmPassword
    }
    func updateSelectedCountryCode(){
        self.buttonCountryCode.setTitle(self.selectedCountryCode, for: .normal)
    }
    func updateTermsAndConditioins(){
        self.imgCheckBox.image = (self.istermsAccepted) ? UIImage.init(named: "checkbox") : UIImage.init(named: "Uncheck")
    }
    
    func isValidSignUp()->Bool{
        /*/
         guard let _ = self.userProfileImage else {
         DispatchQueue.main.async {
         self.buttonParentImage.invalideField()
         self.view.showToast(message:"Please select profile image.", isBlack:true)
         //ShowToast.show(toatMessage: "Please select profile image.")
         }
         return false
         }*/
        guard "\(self.updateParentChildParameters["name"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtDisplayName.invalideFieldWithError(strError: "Please enter valid name")
            }
            return false
        }
        /*
         guard "\(self.updateParentChildParameters["dob"] ?? "")".count > 0 else {
         DispatchQueue.main.async {
         self.txtDateOfBirth.invalideFieldWithError(strError: "Please enter valid DOB")
         }
         return false
         }*/
        guard "\(self.updateParentChildParameters["email"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        if let emailText:String = self.updateParentChildParameters["email"] as? String,!emailText.isValidEmail(){
            DispatchQueue.main.async {
                self.txtEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        /*
         guard "\(self.updateParentChildParameters["password"] ?? "")".count > 0 else {
         DispatchQueue.main.async {
         self.txtPassword.invalideFieldWithError(strError: "Please enter valid password")
         }
         return false
         }
         guard "\(self.updateParentChildParameters["confirm_password"] ?? "")".count > 0 else {
         DispatchQueue.main.async {
         self.txtConfirmPassword.invalideFieldWithError(strError: "Please enter valid confirm password")
         }
         return false
         }
         guard "\(self.updateParentChildParameters["confirm_password"] ?? "")" == "\(self.updateParentChildParameters["password"] ?? "")"  else {
         DispatchQueue.main.async {
         self.txtConfirmPassword.invalideFieldWithError(strError: "Confirm password not match to password")
         }
         return false
         }*/
        guard "\(self.updateParentChildParameters["phone"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtPhoneNumber.invalideFieldWithError(strError: "Please enter valid phone number")
            }
            return false
        }
        //        guard self.istermsAccepted else {
        //            self.view.showToast(message:"Please select terms and conditions.", isBlack:true)
        //            return false
        //        }
        self.txtDisplayName.validateField()
        self.txtDateOfBirth.validateField()
        self.txtEmail.validField()
        self.txtPassword.validField()
        self.txtConfirmPassword.validateField()
        self.txtPhoneNumber.validateField()
        
        return true
    }
    //MARK: - Navigation Methods
    func presentCountryPicker(){
        if let countryPicker = self.storyboard?.instantiateViewController(withIdentifier: "CountryPickerViewController") as? CountryPickerViewController{
            countryPicker.modalPresentationStyle = .overCurrentContext
            countryPicker.delegate = self
            self.navigationController?.present(countryPicker, animated: true, completion: nil)
        }
    }
    func pushToTermsAndCondition(){
        if let webloadViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebLoadViewController") as? WebLoadViewController{
            webloadViewController.objURLString = self.termsConditionsURL
            self.navigationController?.pushViewController(webloadViewController, animated: true)
        }
    }
    //MARK: - API Methods
    func requestAPIForUpdateParent(){
        
        self.updateParentChildParameters["gender"] = self.isBoySelected ? "male" : "female"
        /*
        self.updateParentChildParameters["device_type"] = "ios"
        self.updateParentChildParameters["device_id"] = "\(UIDevice.current.identifierForVendor!.uuidString)"
        if let deviceToken = UserDefaults.standard.object(forKey: "currentDeviceToken") as? String{
            self.updateParentChildParameters["device_token"] = deviceToken
        }else{
            self.updateParentChildParameters["device_token"] = "iOS"
        }*/
        let imageData = self.userProfileImage?.jpeg(.medium) ?? nil
//        self.userProfileImage?.sd_imageData(as: .PNG, compressionQuality: 0.3) ?? nil
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString:(isForChild ? kChildUpdateProfile : kParentChildUpdate) , parameter: self.updateParentChildParameters as [String:AnyObject], imageData:imageData, isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let success = responseSuccess as? [String:Any],let strMSG = success["message"]{
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.view.showToast(message: "\(strMSG)", isBlack: true)
                    //ShowToast.show(toatMessage: "\(strMSG)")
                }
            }
        }) { (responseFail) in
            print(responseFail)
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let objFail = responseFail as? [String:Any],let message:String = objFail["message"] as? String{
                DispatchQueue.main.async {
                    self.view.showToast(message: "\(message)", isBlack: true)
                    //ShowToast.show(toatMessage: message)
                }
            }
        }
    }
    
    //MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonCountryPickerSelector(sender:UIButton){
        //present country picker
        self.presentCountryPicker()
    }
    @IBAction func buttonUploadImageSelector(sender:UIButton){
        self.presentUploadImageActionSheet()
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
    @IBAction func buttonContainerViewSelection(sender:UIButton){
        self.view.endEditing(true)
    }
    @IBAction func buttonCheckBoxSelector(sender:UIButton){
        self.istermsAccepted = !self.istermsAccepted
    }
    @IBAction func buttonSignUpSelector(sender:UIButton){
        if self.isValidSignUp(){
            self.requestAPIForUpdateParent()
        }
    }
    @IBAction func buttonBoySelector(sender:UIButton){
        self.isBoySelected = true
    }
    @IBAction func buttonGirlSelector(sender:UIButton){
        self.isBoySelected = false
    }
    func presentUploadImageActionSheet(){
        let actionSheetController = UIAlertController.init(title: "", message:"Upload Profile Image", preferredStyle: .actionSheet)
        let cancelSelector = UIAlertAction.init(title: "Cancel", style: .cancel, handler:nil)
        actionSheetController.addAction(cancelSelector)
        let cameraSelector = UIAlertAction.init(title: "Camera", style: .default) { (_) in
            
            DispatchQueue.main.async {
                self.objImagePickerController = UIImagePickerController()
                self.objImagePickerController.sourceType = .camera
                self.objImagePickerController.delegate = self
                self.objImagePickerController.allowsEditing = false
                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                self.view.endEditing(true)
                self.presentImagePickerController()
            }
        }
        actionSheetController.addAction(cameraSelector)
        
        let photosSelector = UIAlertAction.init(title: "Photos", style: .default) { (_) in
            DispatchQueue.main.async {
                self.objImagePickerController = UIImagePickerController()
                self.objImagePickerController.sourceType = .savedPhotosAlbum
                self.objImagePickerController.delegate = self
                self.objImagePickerController.allowsEditing = false
                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                self.view.endEditing(true)
                self.presentImagePickerController()
                
            }
        }
        actionSheetController.addAction(photosSelector)
        self.view.endEditing(true)
        //        actionSheetController.view.tintColor = kThemeColor
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceRect = self.buttonCamera.bounds
            popoverController.sourceView = self.buttonCamera
            
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func presentImagePickerController(){
        self.view.endEditing(true)
        self.present(self.objImagePickerController, animated: true, completion: nil)
    }
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let termsRange = (text as NSString).range(of: "Terms and Conditions.")
        
        // comment for now
        //let privacyRange = (text as NSString).range(of: "Privacy Policy")
        
        if gesture.didTapAttributedTextInLabel(label: self.lblTermsAndCondition, inRange: termsRange) {
            print("Tapped terms")
            self.pushToTermsAndCondition()
        }
    }
    
    
    
}

extension ParentEditChildViewController:CountryPickerDelegate{
    func didselectCountryCodewith(country: CountryCode) {
        self.selectedCountryCode = country.dialCode
        self.updateParentChildParameters["country_code"] = "\(country.dialCode)"
    }
}

extension ParentEditChildViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            dismiss(animated: false, completion: nil)
            return
        }
        guard let editedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            dismiss(animated: false, completion: nil)
            return
        }
        picker.dismiss(animated: true, completion: nil)
        self.userProfileImage = originalImage
        self.buttonParentImage.setImage(originalImage, for: .normal)
        //self.buttonParentImage.setBackgroundImage(originalImage, for: .normal)
        //self.presentImageEditor(image: originalImage)
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension ParentEditChildViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard typpedString.canBeConverted(to: String.Encoding.ascii) else {
                   return false
        }
        guard !typpedString.isContainWhiteSpace() else{
              if textField == self.txtDisplayName{
                  return true
              }else{
                  return false
              }
        }
       
        
    
        
        /*
         self.updateParentChildParameters["name"] = "Test"
         self.updateParentChildParameters["email"] = "darshanp12@itpathsolutions.in"
         self.updateParentChildParameters["password"] = "ips12345"
         self.updateParentChildParameters["confirm_password"] = "ips12345"
         self.updateParentChildParameters["country_code"] = "91"
         self.updateParentChildParameters["phone"] = "878787877887"
         */
        
        if textField == self.txtDisplayName{
            self.txtDisplayName.validateField()
            self.updateParentChildParameters["name"] = "\(typpedString)"
        }else if textField == self.txtEmail{
            self.txtEmail.validateField()
            self.updateParentChildParameters["email"] = "\(typpedString)"
        }else if textField == self.txtPassword{
            self.txtPassword.validateField()
            self.updateParentChildParameters["password"] = "\(typpedString)"
        }else if textField == self.txtConfirmPassword{
            self.txtConfirmPassword.validateField()
            self.updateParentChildParameters["confirm_password"] = "\(typpedString)"
        }else{
            self.txtPhoneNumber.validateField()
            self.updateParentChildParameters["phone"] = "\(typpedString)"
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.txtDisplayName{
            self.updateParentChildParameters["name"] = ""
        }else{
            self.updateParentChildParameters["phone"] = ""
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.txtDisplayName{
            self.txtEmail.becomeFirstResponder()
        }else if textField == self.txtEmail{
            self.txtPassword.becomeFirstResponder()
        }else if textField == self.txtPassword{
            self.txtConfirmPassword.becomeFirstResponder()
        }else if textField == self.txtConfirmPassword{
            self.txtPhoneNumber.becomeFirstResponder()
        }else if textField == self.txtPhoneNumber{
            self.buttonSignUpSelector(sender: self.buttonSignUp)
        }
        return true
    }
}
