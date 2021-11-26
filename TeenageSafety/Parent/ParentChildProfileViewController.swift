//
//  ParentChildProfileViewController.swift
//  TeenageSafety
//
//  Created by user on 05/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MaterialTextField
import SDWebImage

class ParentChildProfileViewController: UIViewController {

    @IBOutlet var childCollectionView:UICollectionView!
    var arrayOfChild:[ChildModel] = []

    @IBOutlet var txtName:MFTextField!
    @IBOutlet var txtEmail:MFTextField!
    @IBOutlet var txtPhoneNumber:MFTextField!
    
    var currentChild:Child?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureChildCollectionView()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentChildID:String =  UserDefaults.standard.value(forKey: "currentChild") as? String{
            self.getParentChildProfileAPI(id:currentChildID)
        }
        self.getParentChildListAPI()
    }
    func configureChildCollectionView(){
        self.childCollectionView.delegate = self
        self.childCollectionView.dataSource = self
        self.childCollectionView.reloadData()
        self.childCollectionView.allowsSelection = true
    }
    func configureCurrentUser(){
        if let objChild:Child = self.currentChild{
           
            DispatchQueue.main.async {
                self.txtName.text = objChild.childName
                self.txtEmail.text = objChild.childEmail
                self.txtPhoneNumber.text = "(\(objChild.childCountryCode))  \(objChild.childPhone)"
            }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonAddChildSelector(sender:UIButton){
        self.pushToAddChildViewController()
    }
    @IBAction func buttonChildSelector(sender:UIButton){
        if let app = UIApplication.shared.delegate as? AppDelegate{
            let objChild = self.arrayOfChild[sender.tag]
            app.currentChildID = objChild.id
            self.saveSelectedChild(id: app.currentChildID ?? "0")
            self.childCollectionView.reloadData()
            self.childCollectionView.layoutIfNeeded()
            self.getParentChildProfileAPI(id: objChild.id)

            //self.childCollectionView.scrollToItem(at: IndexPath.init(row: sender.tag, section: 0), at: .left, animated: true)
        }
    }
    @IBAction func buttonLockAppSelector(sender:UIButton){
        if let appDel = UIApplication.shared.delegate as? AppDelegate{
            if !appDel.isSprint1Only{
                if let objChildAppListViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildAppListViewController") as? ChildAppListViewController{
                    if let _ = self.currentChild{
                        objChildAppListViewController.currentChild = self.currentChild!
                    }
                    self.navigationController?.pushViewController(objChildAppListViewController, animated: true)
                }
            }
        }
    }
    
    @IBAction func buttonLeaderBoardSelector(sender:UIButton){
        self.tabBarController?.selectedIndex = 1
        self.navigationController?.popToRootViewController(animated: true)
        
        
    }
    @IBAction func buttonChildChangePasswordSelector(sender:UIButton){
        if let objParentChangePasswordViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordViewController") as? ParentChangePasswordViewController{
            objParentChangePasswordViewController.isForChild = true
            if let objChild = self.currentChild{
                objParentChangePasswordViewController.currentChild = objChild
            }
            self.navigationController?.pushViewController(objParentChangePasswordViewController, animated: true)
        }
    }
    @IBAction func buttonEditChildSelector(sender:UIButton){
        if let _ = self.currentChild{
            self.pushToParentEditChildViewController(currentChid: self.currentChild!)
        }
        
    }
    @IBAction func buttonDeleteChildSelector(sender:UIButton){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Child Delete", message: "Are you sure you want to delete child?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {
                action in
                alert.dismiss(animated: false, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                if let objChild:Child = self.currentChild{
                    self.deleteChildProfileAPIRequest(childID: objChild.childId)
                }
                alert.dismiss(animated: false, completion: nil)
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - API Request
    func getParentChildProfileAPI(id:String){
        var childProfile:[String:Any] = [:]
        childProfile["id"] = "\(id)"
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentGETChildProfile, parameter:childProfile as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
//            print(responseSuccess)
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [String:Any]{
                print(successData)
                self.currentChild = Child.init(userDetail: successData)
                self.configureCurrentUser()
                
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
                    self.childCollectionView.layoutIfNeeded()
                    //self.childCollectionView.scrollToItem(at: IndexPath.init(row: 2, section: 0), at: .centeredHorizontally, animated: true)
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
    //Delete Child Profile API Request
    func deleteChildProfileAPIRequest(childID:String){
        
        var deleteChildProfileParamters:[String:Any] = [:]
        deleteChildProfileParamters["id"] = "\(childID)"
        //kParentDeleteChild
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentDeleteChild, parameter:deleteChildProfileParamters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            //            print(responseSuccess)
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String{
                self.navigationController?.popViewController(animated: true)
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
    
    func saveSelectedChild(id:String){
        UserDefaults.standard.set(id, forKey: "currentChild")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToAddChildViewController(){
        if let objAddChildViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddChildViewController") as? AddChildViewController{
            self.navigationController?.pushViewController(objAddChildViewController, animated: true)
        }
    }
    
    func pushToParentEditChildViewController(currentChid:Child){
        if let objParentEditChildViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentEditChildViewController") as? ParentEditChildViewController{
            objParentEditChildViewController.currentChild = currentChid
            self.navigationController?.pushViewController(objParentEditChildViewController, animated: true)
        }
    }
}
extension ParentChildProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrayOfChild.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let childCell:ChildCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildCollectionViewCell", for: indexPath) as! ChildCollectionViewCell
        childCell.buttonAddChild.isHidden = indexPath.item != self.arrayOfChild.count
        childCell.buttonChild.isHidden = indexPath.item == self.arrayOfChild.count
        
        childCell.buttonAddChild.addTarget(self, action: #selector(buttonAddChildSelector(sender:)), for: .touchUpInside)
        childCell.buttonChild.tag = indexPath.item
        childCell.buttonChild.addTarget(self, action: #selector(buttonChildSelector(sender:)), for: .touchUpInside)
        
        if self.arrayOfChild.count > indexPath.item{
            let objChild = self.arrayOfChild[indexPath.item]
             let objURL = URL.init(string: objChild.image)
            childCell.buttonChild.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: nil)
            childCell.buttonChild.imageView?.contentMode = .scaleAspectFill
            childCell.buttonChild.layer.borderWidth = 2.0
            childCell.buttonChild.layer.borderColor = (self.getIndexOfCurrentChild(child: objChild)) ? kThemeColor.cgColor : UIColor.clear.cgColor
            if (self.getIndexOfCurrentChild(child: objChild)){
                childCell.buttonChild.layer.cornerRadius = 40.0
            }else{
                childCell.buttonChild.layer.cornerRadius = 25.0
            }
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
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if self.arrayOfChild.count > indexPath.item{
            let objChild = self.arrayOfChild[indexPath.item]
            let objSize = CGSize.init(width: 50.0, height:  50.0)
            let objUpdateSize = CGSize.init(width: 80.0, height:  80.0)
            if (self.getIndexOfCurrentChild(child: objChild)){
                return objUpdateSize
            }else{
                return objSize
            }
        }else{
            return CGSize.init(width: 50.0, height:  50.0)
        }
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: collectionView.bounds.width/5, height: collectionView.bounds.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.init(width: collectionView.bounds.width/5, height: collectionView.bounds.height)
    }
    /*
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
        /*
        if indexPath.item == 0{
            self.pushToAddChildViewController()
        }else{
            if let app = UIApplication.shared.delegate as? AppDelegate{
                let objChild = self.arrayOfChild[indexPath.item - 1]
                app.currentChildID = objChild.id
                self.saveSelectedChild(id: app.currentChildID ?? "0")
                self.childCollectionView.reloadData()
            }
        }*/
    }
}
