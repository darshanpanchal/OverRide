//
//  ParentProfileViewController.swift
//  TeenageSafety
//
//  Created by user on 03/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import SDWebImage
import MaterialTextField

class ParentProfileViewController: UIViewController {

    @IBOutlet var buttonProfile:RoundButton!
    @IBOutlet var lblName:UILabel!
    
    @IBOutlet var txtEmail:MFTextField!
    @IBOutlet var txtPhoneNumber:MFTextField!
    @IBOutlet var buttonAddChild:RoundButton!
    
    @IBOutlet var childCollectionView:UICollectionView!
    
    var arrayOfChild:[ChildModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getParentProfileAPI()
        self.getParentChildListAPI()
    }
    // MARK: - Setup Methods
    func setup(){
        self.txtEmail.isEnabled = false
        self.txtPhoneNumber.isEnabled = false
//
        self.buttonProfile.imageView?.contentMode = .scaleAspectFill
        //configure parent detail
        self.configureCurrentUser()
        //Configure child collectionview
        self.configureChildCollectionView()
    }
    func configureCurrentUser(){
        if let objParent:Parent = Parent.getParentFromUserDefault(){
             let objURL = URL.init(string: objParent.parentImage)
             self.buttonProfile.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: nil)

            
            DispatchQueue.main.async {
                self.lblName.text = objParent.parentName
                self.txtEmail.text = objParent.parentEmail
                self.txtPhoneNumber.text = "(\(objParent.parentCountryCode))  \(objParent.parentPhone)"
            }
        }
    }
    func configureChildCollectionView(){
        self.childCollectionView.delegate = self
        self.childCollectionView.dataSource = self
        self.childCollectionView.reloadData()
        self.childCollectionView.allowsSelection = true
    }
    // MARK: - API Methods
    func getParentProfileAPI(){
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: kParentProfile, parameter:nil, isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [String:Any]{
                let objParent = Parent.init(userDetail: successData, isUpdateProfile: true)
                objParent.setParentDetailToUserDefault()
                self.configureCurrentUser()
                DispatchQueue.main.async {
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
    func getParentChildListAPI(){
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: kParentChildList, parameter:nil, isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [String:Any]{
                if let arrayChild:[[String:Any]] = successData["child"] as? [[String:Any]]{
                    self.arrayOfChild.removeAll()
                    for var childJSON:[String:Any] in arrayChild{
                        
                        childJSON.updateJSONNullToString()
                        childJSON.updateJSONToString()
                        
                        do {
                            let jsondata = try JSONSerialization.data(withJSONObject:childJSON, options:.prettyPrinted)
                            
                            if let achievementData = try? JSONDecoder().decode(ChildModel.self, from: jsondata){
                                self.arrayOfChild.append(achievementData)
                            }
                            
                        }catch{
                            
                        }
                    }
                }
                DispatchQueue.main.async {
                    if let app = UIApplication.shared.delegate as? AppDelegate{
                        if let objID = app.currentChildID{
                            
                        }else{
                            if self.arrayOfChild.count > 0{
                                app.currentChildID = self.arrayOfChild.first!.id
                                self.saveSelectedChild(id: app.currentChildID ?? "0")
                            }
                            
                        }
                    }
                   self.childCollectionView.reloadData()
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
                    //                        ShowToast.show(toatMessage: message)
                }
            }
        }
    }
    func saveSelectedChild(id:String){
        UserDefaults.standard.set(id, forKey: "currentChild")
        UserDefaults.standard.synchronize()
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.popToBackViewController()
        }
        
    }
    @IBAction func buttonEditProfileSelector(sender:UIButton){
        self.pushToEditProfileViewController()
    }
    @IBAction func buttonAddChildSelector(sender:UIButton){
        self.pushToAddChildViewController()
    }
    @IBAction func buttonChildSelector(sender:UIButton){
        if let app = UIApplication.shared.delegate as? AppDelegate{
            let objChild = self.arrayOfChild[sender.tag - 1]
            app.currentChildID = objChild.id
            self.saveSelectedChild(id: app.currentChildID ?? "0")
            self.childCollectionView.reloadData()
            self.pushToParentChildProfileViewController()
        }
    }
    @IBAction func buttonLogOutSelector(sender:UIButton){
        Parent.removeParentFromUserDefault()
        //self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        if let objTabBar = self.tabBarController,let tabNavigationViewController = objTabBar.navigationController{
            for controller in tabNavigationViewController.viewControllers {
                if controller.isKind(of: UserRoleViewController.self) {
                    tabNavigationViewController.popToViewController(controller, animated: true)
                    break
                }
            }
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
    func pushToEditProfileViewController(){
        if let objParentEditProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentEditProfileViewController") as? ParentEditProfileViewController{
            self.navigationController?.pushViewController(objParentEditProfileViewController, animated: true)
        }
    }
    func pushToAddChildViewController(){
        if let objAddChildViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddChildViewController") as? AddChildViewController{
            self.navigationController?.pushViewController(objAddChildViewController, animated: true)
        }
    }
    func pushToParentChildProfileViewController(){
        if let objParentChildProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentChildProfileViewController") as? ParentChildProfileViewController{
            self.navigationController?.pushViewController(objParentChildProfileViewController, animated: true)
        }
    }
}
extension ParentProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrayOfChild.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let childCell:ChildCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildCollectionViewCell", for: indexPath) as! ChildCollectionViewCell
        childCell.buttonAddChild.isHidden = indexPath.item != 0
        childCell.buttonChild.isHidden = indexPath.item == 0
        childCell.buttonAddChild.addTarget(self, action: #selector(buttonAddChildSelector(sender:)), for: .touchUpInside)
        childCell.buttonChild.tag = indexPath.item
        childCell.buttonChild.addTarget(self, action: #selector(buttonChildSelector(sender:)), for: .touchUpInside)
        
        if indexPath.item > 0{
            let objChild = self.arrayOfChild[indexPath.item - 1]
            
             let objURL = URL.init(string: objChild.image)
             childCell.buttonChild.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: nil)
            childCell.buttonChild.imageView?.contentMode = .scaleAspectFill
            childCell.buttonChild.layer.borderWidth = 2.0
            childCell.buttonChild.layer.borderColor = (self.getIndexOfCurrentChild(child: objChild)) ? kThemeColor.cgColor : UIColor.clear.cgColor
            
        }
        return childCell
    }
    func getIndexOfCurrentChild(child:ChildModel)->Bool{
        if let app = UIApplication.shared.delegate as? AppDelegate{
            if let objID = app.currentChildID,objID == child.id{
                return true
            }else{
                return false
            }
        }
        return false
    }
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: UIScreen.main.bounds.width/3, height:  UIScreen.main.bounds.width/2.5)//collectionView.bounds.size.width*0.5+50+30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let user = User.getUserFromUserDefault(){
            guard user.userType == .admin else{
                return CGSize.zero
            }
        }
        return CGSize.init(width: collectionView.bounds.width, height: 85.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero//UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0//15.0
    }*/
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0{
            self.pushToAddChildViewController()
        }else{
            if let app = UIApplication.shared.delegate as? AppDelegate{
                let objChild = self.arrayOfChild[indexPath.item - 1]
                app.currentChildID = objChild.id
                self.saveSelectedChild(id: app.currentChildID ?? "0")
                self.childCollectionView.reloadData()
                self.pushToParentChildProfileViewController()
        }
      }
    }
}
class ChildCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet var buttonChild:RoundButton!
    @IBOutlet var buttonAddChild:RoundButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonAddChild.imageView?.contentMode = .scaleAspectFit
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.buttonAddChild.isHidden = true
        self.buttonChild.isHidden = true
    }
}
struct ChildModel: Codable {
   
    let id, image, name, phone, email, dob, country_code, access_token, gender,udid: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case image
        case name
        case phone
        case email
        case dob
        case country_code
        case access_token
        case gender
        case udid
    }
  
    init(from decoder:Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.image = try values.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.phone = try values.decodeIfPresent(String.self, forKey: .phone) ?? ""
        self.email = try values.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.dob = try values.decodeIfPresent(String.self, forKey: .dob) ?? ""
        self.country_code = try values.decodeIfPresent(String.self, forKey: .country_code) ?? ""
        self.access_token = try values.decodeIfPresent(String.self, forKey: .access_token) ?? ""
        self.gender = try values.decodeIfPresent(String.self, forKey: .gender) ?? ""
        self.udid = try values.decodeIfPresent(String.self, forKey: .udid) ?? ""
        
    }
}

