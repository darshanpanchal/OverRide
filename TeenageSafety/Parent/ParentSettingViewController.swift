//
//  ParentSettingViewController.swift
//  TeenageSafety
//
//  Created by user on 03/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ParentSettingViewController: UIViewController {

    
    @IBOutlet var collectionViewSetting:UICollectionView!
    
    var arrayOfSetting:[ParentSetting] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        // Do any additional setup after loading the view.
        self.configureCollectionView()
    }
    
    // MARK: - Custom Methods
    func setUp(){
        self.arrayOfSetting.append(ParentSetting.init(imageName: "setting_lock", strSetting: "Change Account Password"))
        self.arrayOfSetting.append(ParentSetting.init(imageName: "setting_user", strSetting: "Edit Profile"))
        self.arrayOfSetting.append(ParentSetting.init(imageName: "setting_notification", strSetting: "Notification Setting"))
        
    }
    func configureCollectionView(){
        let objNib = UINib.init(nibName: "SettingCollectionViewCell", bundle: nil)
        self.collectionViewSetting.register(objNib, forCellWithReuseIdentifier: "SettingCollectionViewCell")
        self.collectionViewSetting.delegate = self
        self.collectionViewSetting.dataSource = self
        self.collectionViewSetting.reloadData()
        self.collectionViewSetting.allowsSelection = true
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.popToBackViewController()
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
    func pushToParentChangePasswordViewController(){
        if let objParentChangePasswordViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordViewController") as? ParentChangePasswordViewController{
            self.navigationController?.pushViewController(objParentChangePasswordViewController, animated: true)
        }
    }
    func pushToParentNotificationSettingViewController(){
        if let objParentNotificationSettingViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentNotificationSettingViewController") as? ParentNotificationSettingViewController{
            self.navigationController?.pushViewController(objParentNotificationSettingViewController, animated: true)
        }
    }
}
extension ParentSettingViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.arrayOfSetting.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let settingCell:SettingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingCollectionViewCell", for: indexPath) as! SettingCollectionViewCell
        let objSetting = self.arrayOfSetting[indexPath.item]
        settingCell.imageSetting.image = UIImage.init(named: objSetting.imageName)
        settingCell.lblSetting.text = objSetting.strSetting
            
        return settingCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: UIScreen.main.bounds.width/2, height:  UIScreen.main.bounds.width/2)//collectionView.bounds.size.width*0.5+50+30)
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero//UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0//15.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0{//change password
            self.pushToParentChangePasswordViewController()
        }else if indexPath.item == 1{ //edit profile
            self.pushToEditProfileViewController()
        }else{//notification
            self.pushToParentNotificationSettingViewController()
        }
    }
}
struct ParentSetting {
    var imageName,strSetting:String
}
