//
//  ParentSignUpViewController.swift
//  TeenageSafety
//
//  Created by IPS on 21/11/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MobileCoreServices
import MaterialTextField

class ParentSignUpViewController: UIViewController {

    @IBOutlet weak var tblParentSignup:UITableView!
    @IBOutlet var lblTermsAndCondition:UILabel!
    
    @IBOutlet var buttonCountryCode:UIButton!
    
    @IBOutlet var buttonSignUp:UIButton!
    
    @IBOutlet var buttonCamera:UIButton!
    @IBOutlet var buttonParentImage:RoundButton!
    
    @IBOutlet var txtDisplayName:MFTextField!
    @IBOutlet var txtEmail:MFTextField!
    @IBOutlet var txtPassword:MFTextField!
    @IBOutlet var txtConfirmPassword:MFTextField!
    @IBOutlet var txtPhoneNumber:MFTextField!
    
    @IBOutlet var imgCheckBox:UIImageView!
    
    @IBOutlet var containerTermsAndConditions:UIView!
    
    @IBOutlet var imageViewCamera:UIImageView!
    
    var userProfileImage:UIImage?
    
    var isPasswordShow:Bool = false
    var isConfirmPasswordShow:Bool = false
    
    var objPassword:UIButton?
    var objConfirmPassword:UIButton?
    
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
    

    var userfieldsName = ["Display Name","Email","Password","Confirm Password","Phone No"]
    
    var addParentParameters:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUp()
        
    }
    //MARK: - SetUp Methods
    func setUp(){
        self.configureTermsAndCondition()
        self.txtDisplayName.setUpWithPlaceHolder(strPlaceHolder: "Display Name")
        self.txtEmail.setUpWithPlaceHolder(strPlaceHolder: "Email")
        self.txtPassword.setUpWithPlaceHolder(strPlaceHolder: "Password")
        self.txtConfirmPassword.setUpWithPlaceHolder(strPlaceHolder: "Confirm Password")
        self.txtPhoneNumber.setUpWithPlaceHolder(strPlaceHolder: "Phone Number")
        self.configurePasswordTextField()
        self.configureConfirmPasswordTextField()
        self.buttonParentImage.imageView?.contentMode = .scaleAspectFill
        
        self.addParentParameters["country_code"] = "1"
        
        self.txtDisplayName.delegate = self
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self
        self.txtConfirmPassword.delegate = self
        self.txtPhoneNumber.delegate = self
        self.istermsAccepted = true
        
        
        self.imageViewCamera.layer.borderColor = UIColor.clear.cgColor
        self.imageViewCamera.layer.cornerRadius = 15.0
        self.imageViewCamera.clipsToBounds = true
        self.imageViewCamera.layer.borderWidth = 1.0
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
    func configureTermsAndCondition(){
        lblTermsAndCondition.text = text
        self.lblTermsAndCondition.textColor =  UIColor.white
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms and Conditions.")
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name:"Poppins-Regular", size: 14.0)!, range: range1)
        
        lblTermsAndCondition.attributedText = underlineAttriString
        lblTermsAndCondition.isUserInteractionEnabled = true
        lblTermsAndCondition.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
        
    }
    func isValidSignUp()->Bool{
       
        guard let _ = self.userProfileImage else {
            DispatchQueue.main.async {
                self.buttonParentImage.invalideField()
                self.view.showToast(message:"Please select profile image.", isBlack:false)
                //ShowToast.show(toatMessage: "Please select profile image.")
            }
            return false
        }
        guard "\(self.addParentParameters["name"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtDisplayName.invalideFieldWithError(strError: "Please enter valid name")
            }
            return false
        }
        guard "\(self.addParentParameters["email"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        if let emailText:String = self.addParentParameters["email"] as? String,!emailText.isValidEmail(){
            DispatchQueue.main.async {
                self.txtEmail.invalideFieldWithError(strError: "Please enter valid email address.")
            }
            return false
        }
        
        guard "\(self.addParentParameters["password"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtPassword.invalideFieldWithError(strError: "Please enter valid password")
            }
            return false
        }
        guard "\(self.addParentParameters["confirm_password"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtConfirmPassword.invalideFieldWithError(strError: "Please enter valid confirm password")
            }
            return false
        }
        guard "\(self.addParentParameters["confirm_password"] ?? "")" == "\(self.addParentParameters["password"] ?? "")"  else {
            DispatchQueue.main.async {
                self.txtConfirmPassword.invalideFieldWithError(strError: "Confirm password not match to password")
            }
            return false
        }
        guard "\(self.addParentParameters["phone"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtPhoneNumber.invalideFieldWithError(strError: "Please enter valid phone number")
            }
            return false
        }
        guard self.istermsAccepted else {
            self.view.showToast(message:"Please select terms and conditions.", isBlack:false)
            return false
        }
        self.txtDisplayName.validateField()
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
    //MARK: - API Methods
    func requestAPIForParentSignUp(){
        /*
        self.addParentParameters["name"] = "Test"
        self.addParentParameters["email"] = "darshanp12@itpathsolutions.in"
        self.addParentParameters["password"] = "ips12345"
        self.addParentParameters["confirm_password"] = "ips12345"
        self.addParentParameters["country_code"] = "91"
        self.addParentParameters["phone"] = "878787877887"
        self.addParentParameters["device_type"] = "ios"
        self.addParentParameters["device_token"] = "sdasdadddasdaddadsd"
        self.addParentParameters["device_id"] = "dsfsdfsdfsdsff"
        */
        self.addParentParameters["device_type"] = "ios"
        self.addParentParameters["device_id"] = "\(UIDevice.current.identifierForVendor!.uuidString)"
        if let deviceToken = UserDefaults.standard.object(forKey: "currentDeviceToken") as? String{
            self.addParentParameters["device_token"] = deviceToken
        }else{
            self.addParentParameters["device_token"] = "iOS"
        }
        let imageData = self.userProfileImage?.jpeg(.medium) ?? nil
        //self.userProfileImage!.sd_imageData(as: .PNG, compressionQuality: 0.3)
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kParentSignUp , parameter: addParentParameters as [String:AnyObject], imageData:imageData , isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [String:Any]{
                let objParent = Parent.init(userDetail: successData)
                objParent.setParentDetailToUserDefault()
                DispatchQueue.main.async {
                    self.view.showToast(message: message, isBlack: false)
                    self.pushToParentHomeController()
                }
            }
        }) { (responseFail) in
            print(responseFail)
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let objFail = responseFail as? [String:Any],let message:String = objFail["message"] as? String{
                DispatchQueue.main.async {
                    self.view.showToast(message: "\(message)", isBlack: false)
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
            self.requestAPIForParentSignUp()
        }
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
extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
        //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
        // locationOfTouchInLabel.y - textContainerOffset.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
extension ParentSignUpViewController:CountryPickerDelegate{
    func didselectCountryCodewith(country: CountryCode) {
        self.selectedCountryCode = country.dialCode
        self.addParentParameters["country_code"] = "\(country.dialCode)"
    }
}

extension ParentSignUpViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
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
        self.imageViewCamera.layer.borderColor = UIColor.white.cgColor
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
extension ParentSignUpViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        if textField != self.txtDisplayName{
            guard !typpedString.isContainWhiteSpace() else{
                
                return false
            }
        }        
  
        
        if textField == self.txtDisplayName{
            self.txtDisplayName.validateField()
            self.addParentParameters["name"] = "\(typpedString)"
        }else if textField == self.txtEmail{
            self.txtEmail.validateField()
            self.addParentParameters["email"] = "\(typpedString)"
        }else if textField == self.txtPassword{
            self.txtPassword.validateField()
            self.addParentParameters["password"] = "\(typpedString)"
        }else if textField == self.txtConfirmPassword{
            self.txtConfirmPassword.validateField()
            self.addParentParameters["confirm_password"] = "\(typpedString)"
        }else{
            self.txtPhoneNumber.validateField()
            self.addParentParameters["phone"] = "\(typpedString)"
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.txtDisplayName{
            self.addParentParameters["name"] = ""
        }else{
            self.addParentParameters["phone"] = ""
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
extension UIImage {
    func fixedOrientation() -> UIImage {
        
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2)
        case .up, .upMirrored:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        if let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace,
            let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            ctx.concatenate(transform)
            
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            if let ctxImage: CGImage = ctx.makeImage() {
                return UIImage(cgImage: ctxImage)
            } else {
                return self
            }
        } else {
            return self
        }
    }
}
