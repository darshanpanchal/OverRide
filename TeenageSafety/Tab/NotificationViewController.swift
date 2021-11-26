//
//  NotificationViewController.swift
//  TeenageSafety
//
//  Created by user on 04/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    
    var arrayOfNotification:[String] = ["Email Notification","Push Notification","Speed Alert","Low Fuel Level","Low Oil Level","Weekly Summary report","Good Daily Driver"]
    
    @IBOutlet var tableViewCountryCode:UITableView!

    var selectionSet:NSMutableSet = NSMutableSet()
    
    var arrayOfNotificatioList:[NotificationList] = []
    
    @IBOutlet var containerView:UIView!
    
    var filterParameters:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure TableView
        self.configureTableView()
        // Do any additional setup after loading the view.
        
    }
  
    func configureTableView(){
        let objNIB = UINib.init(nibName: "NotificationTableViewCell", bundle: nil)
        self.tableViewCountryCode.register(objNIB, forCellReuseIdentifier: "NotificationTableViewCell")
        self.tableViewCountryCode.allowsSelection = true
        self.tableViewCountryCode.delegate = self
        self.tableViewCountryCode.dataSource = self
        self.tableViewCountryCode.reloadData()
    }
     // MARK: - API Request Methods
    func getParentNotificationListAPIRequest(filterParameters:[String:Any]){
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentGETNotificationList, parameter:self.filterParameters as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    self.arrayOfNotificatioList.removeAll()
                    if let arrayData:[[String:Any]] = objSuccess["data"] as? [[String:Any]]{
                        for var objData in arrayData{
                            if "\(objData["type"] ?? "")" == "bluetooth"{
                                let objNotification = NotificationList.init(childName: "\(objData["childname"] ?? "")", id: "\(objData["id"] ?? "")", image: "\(objData["image"] ?? "")", title: "\(objData["title"] ?? "")", creatDate: "\(objData["created_at"] ?? "")", type: "\(objData["type"] ?? "")", readAt: "\(objData["read_at"] ?? "")", updateDate: "\(objData["updated_at"] ?? "")", appID: "", appJSON: [:])
                            
                                self.arrayOfNotificatioList.append(objNotification)
                            }else{
                                if let appJSON = objData["data"] as? [String:Any],let appID = appJSON["id"],let appArray = appJSON["data"] as? [[String:Any]], appArray.count > 0{
                                    let objNotification = NotificationList.init(childName: "\(objData["childname"] ?? "")", id: "\(objData["id"] ?? "")", image: "\(objData["image"] ?? "")", title: "\(objData["title"] ?? "")", creatDate: "\(objData["created_at"] ?? "")", type: "\(objData["type"] ?? "")", readAt: "\(objData["read_at"] ?? "")", updateDate: "\(objData["updated_at"] ?? "")", appID: "\(appID)", appJSON: appArray.first!)
                                    self.arrayOfNotificatioList.append(objNotification)
                                }
                            }
                        }
                    }
                    self.tableViewCountryCode.reloadData()
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
    func updateParentRequestAccessAPI(updateParameters:[String:Any]){
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentChildAppAccess, parameter:updateParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    if let keyWindow = UIApplication.shared.keyWindow{
                        keyWindow.showToast(message: message, isBlack: true)
                    }
                    
                    self.getParentNotificationListAPIRequest(filterParameters: self.filterParameters)
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let appDel = UIApplication.shared.delegate as? AppDelegate{
            self.containerView.isHidden = appDel.isSprint1Only
            
        }
        //get parent notification
        self.getParentNotificationListAPIRequest(filterParameters: self.filterParameters)
    }
    // MARK: - Selector Methods
    @IBAction func buttonFilterSelector(sender:UIButton){
        self.pushToFilterViewController()
    }
    @IBAction func buttonProfileSelector(sender:UIButton){
        self.pushToParentProfileViewController()
    }
    /*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }*/

    func pushToFilterViewController(){
        if let objViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationFilterViewController") as? NotificationFilterViewController{
            objViewController.hidesBottomBarWhenPushed = true
            objViewController.filterDelegate = self
            objViewController.notificationFilter = self.filterParameters
            self.navigationController?.pushViewController(objViewController, animated: false)
        }
    }
    func pushToParentProfileViewController(){
        if let objParentProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentProfileViewController") as? ParentProfileViewController{
            objParentProfileViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objParentProfileViewController, animated: true)
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
extension NotificationViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfNotificatioList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as! NotificationTableViewCell
        let objNotification = self.arrayOfNotificatioList[indexPath.row]

        objCell.lblChildName.text = "\(objNotification.childName) \(objNotification.title)"
        let objURL = URL.init(string: objNotification.image)
        objCell.buttonChild.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: nil)
        objCell.buttonChildCollapase.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "update_user_placeholder") , options: .refreshCached, progress: nil, completed: nil)
        objCell.lblAppName.text = "\(objNotification.appJSON["name"] ?? "")"
        objCell.lblTime.text =  "\(objNotification.updateDate)".changeTimeFormatOverRide + ", " + "\(objNotification.updateDate)".changeDateFormatOverRide
        
        let objAppImageURL = URL.init(string:"\(objNotification.appJSON["image_url"] ?? "")")
        let objDeviceType = "\(objNotification.appJSON["device_type"] ?? "")"
        
        let objPlaceHolder = ((objDeviceType == "android") ? UIImage.init(named: "andro") : UIImage.init(named: "appl"))
        objCell.buttonApp.sd_setImage(with: objAppImageURL, for: .normal, placeholderImage: objPlaceHolder , options: .refreshCached, progress: nil, completed: nil)
          objCell.buttonAppHint.sd_setImage(with: objAppImageURL, for: .normal, placeholderImage: objPlaceHolder , options: .refreshCached, progress: nil, completed: nil)
        if self.selectionSet.contains(indexPath.row){
            objCell.buttonChildCollapase.isHidden = true
            objCell.buttonChild.isHidden = false
            objCell.expandableView.isHidden = false
            objCell.bottomHeight.constant = 20.0
            objCell.containerView.backgroundColor = UIColor.init(hexString: "#F6F6F6")
        }else{
            objCell.buttonChildCollapase.isHidden = false
            objCell.buttonChild.isHidden = true
            objCell.expandableView.isHidden = true
            objCell.bottomHeight.constant = 0.0
            objCell.containerView.backgroundColor = UIColor.white
        }
        objCell.buttonDecline.tag = indexPath.row
        objCell.buttonAccept.tag = indexPath.row
        objCell.buttonAccept.addTarget(self, action: #selector(buttonAppAcceptRequestSelector(sender:)), for: .touchUpInside)
        objCell.buttonDecline.addTarget(self, action: #selector(buttonAppDeclineRequestSelector(sender:)), for: .touchUpInside)
        
        if objNotification.type == "sos" || objNotification.type == "bluetooth"{
            objCell.buttonAppHint.isHidden = true
        }else{
            objCell.buttonAppHint.isHidden = false
        }
        
        if objNotification.type == "pending"{
            objCell.lblStatus.isHidden = true
            objCell.objStackView.isHidden = false
            objCell.lblStatus.text = ""
        }else if objNotification.type == "accept"{
            objCell.objStackView.isHidden = true
            objCell.lblStatus.isHidden = false
            objCell.lblStatus.text = "Approved"
        }else if objNotification.type == "decline"{
            objCell.objStackView.isHidden = true
            objCell.lblStatus.isHidden = false
            objCell.lblStatus.text = "Rejected"
        }else{
            objCell.objStackView.isHidden = true
            objCell.lblStatus.isHidden = true
            objCell.lblStatus.text = ""
        }
        return objCell
    }
    @IBAction func buttonAppAcceptRequestSelector(sender:UIButton){
        let objNotification = self.arrayOfNotificatioList[sender.tag]
        var updateAccessParameters:[String:Any] = [:]
        updateAccessParameters["id"] = "\(objNotification.appID)"
        updateAccessParameters["notification_id"] = "\(objNotification.id)"
        updateAccessParameters["notification_type"] = "accept"
        
        
        var objChildJSON = objNotification.appJSON
        if var statusJSON = objChildJSON["status"] as? [String:Any]{
            statusJSON.updateJSONToString()
            statusJSON["isLocked"] = "false"
            statusJSON["isRequested"] = "false"
            objChildJSON["status"] = statusJSON
        }
        updateAccessParameters["data"] = [objChildJSON]
        self.updateParentRequestAccessAPI(updateParameters: updateAccessParameters)
        
    }
    @IBAction func buttonAppDeclineRequestSelector(sender:UIButton){
        let objNotification = self.arrayOfNotificatioList[sender.tag]
        var updateAccessParameters:[String:Any] = [:]
        updateAccessParameters["id"] = "\(objNotification.appID)"
        updateAccessParameters["notification_id"] = "\(objNotification.id)"
        updateAccessParameters["notification_type"] = "decline"
        
        
        var objChildJSON = objNotification.appJSON
        if var statusJSON = objChildJSON["status"] as? [String:Any]{
            statusJSON.updateJSONToString()
            statusJSON["isLocked"] = "true"
            statusJSON["isRequested"] = "false"
            objChildJSON["status"] = statusJSON
        }
        updateAccessParameters["data"] = [objChildJSON]
        self.updateParentRequestAccessAPI(updateParameters: updateAccessParameters)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectionSet.contains(indexPath.row){
            return 180.0//UITableView.automaticDimension
        }else{
            return 90.0//UITableView.automaticDimension
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objCountry = self.arrayOfNotificatioList[indexPath.row]
        if objCountry.type == "sos" || objCountry.type == "bluetooth"{
            return
        }
        
        if self.selectionSet.contains(indexPath.row){
            self.selectionSet.remove(indexPath.row)
        }else{
            self.selectionSet.add(indexPath.row)
        }
        DispatchQueue.main.async {
            self.tableViewCountryCode.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
}
extension NotificationViewController:FilterDelegate{
    func applyFilterOnSelectedChildDateCategory(filterParameters: [String : Any]) {
        self.filterParameters = filterParameters
        self.getParentNotificationListAPIRequest(filterParameters: filterParameters)
    }
}
class NotificationSettingCell: UITableViewCell {
    
    @IBOutlet var imageNotification:UIImageView!
    @IBOutlet var lblNotificationSetting:UILabel!
    @IBOutlet var buttonNotification:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonNotification.imageView?.contentMode = .scaleAspectFit
        
    }
    @IBAction func buttonSWitchSelector(sender:UIButton){
        //self.buttonNotification.isSelected = !self.buttonNotification.isSelected
    }
}
struct NotificationList {
    var childName, id, image, title:String
    var creatDate, type, readAt, updateDate:String
    var appID:String
    var appJSON:[String:Any]
}
