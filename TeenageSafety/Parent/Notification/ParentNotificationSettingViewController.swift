//
//  ParentNotificationSettingViewController.swift
//  TeenageSafety
//
//  Created by user on 06/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ParentNotificationSettingViewController: UIViewController {

    var arrayOfNotification:[String] = ["Email Notification","Push Notification","Speed Alert","Low Fuel Level","Low Oil Level","Weekly Summary report","Good Daily Driver"]
    
    var arrayOfImage:[String] = ["email_notification","push_notification","speed_alert","fuel_level","oil_level","summary_report","driver"]
    
    @IBOutlet var tableViewNotification:UITableView!
    
    var objSelectedSet:NSMutableSet = NSMutableSet()
    
    var arrayOfNotificationSetting:[NotificationSetting] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        // Do any additional setup after loading the view.
        self.getNotificationAPIRequest()
    }
    func configureTableView(){
        self.tableViewNotification.allowsSelection = true
        self.tableViewNotification.delegate = self
        self.tableViewNotification.dataSource = self
        self.tableViewNotification.reloadData()
    }
    // MARK: - API Request Methods
    func getNotificationAPIRequest(){
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: kParentGETNotification, parameter:nil, isHudeShow: true, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [[String:Any]]{
                self.arrayOfNotificationSetting.removeAll()
                for objJSON in successData{
                    
                    let objNotification = NotificationSetting.init(objStatus: "\(objJSON["status"] ?? "")", name:"\(objJSON["name"] ?? "")", defaultStatus:"\(objJSON["default_status"] ?? "")", id:"\(objJSON["id"] ?? "")")
                    self.arrayOfNotificationSetting.append(objNotification)
                }
                DispatchQueue.main.async {
                    self.tableViewNotification.reloadData()
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
    func updateParentNotificationSetting(id:String,status:String){
        var updateParentParameters:[String:Any] = [:]
        updateParentParameters["id"] = "\(id)"
        if status == "1"{
            updateParentParameters["status"] = "0"
        }else{
            updateParentParameters["status"] = "1"
        }
        print(updateParentParameters)
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentUpdateNotificationSetting, parameter:updateParentParameters as? [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in
            print(responseSuccess)
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [[String:Any]]{
                self.arrayOfNotificationSetting.removeAll()
                for objJSON in successData{
                    let objNotification = NotificationSetting.init(objStatus: "\(objJSON["status"] ?? "")", name:"\(objJSON["name"] ?? "")", defaultStatus:"\(objJSON["default_status"] ?? "")", id:"\(objJSON["id"] ?? "")")
                    self.arrayOfNotificationSetting.append(objNotification)
                }
                DispatchQueue.main.async {
                    self.tableViewNotification.reloadData()
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
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
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
extension ParentNotificationSettingViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfNotificationSetting.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "NotificationSettingCell") as! NotificationSettingCell
        let objSetting = self.arrayOfNotificationSetting[indexPath.row]
        objCell.lblNotificationSetting.text = objSetting.name
        if let objImage = UIImage.init(named: "\(self.arrayOfImage[indexPath.row])"){
            objCell.imageNotification.image = objImage
        }
        
        if objSetting.objStatus == "1"{
            objCell.buttonNotification.isSelected = true
        }else if objSetting.objStatus == "0"{
            objCell.buttonNotification.isSelected = false
         }else{
            objCell.buttonNotification.isSelected = false
         }
        objCell.buttonNotification.addTarget(self, action: #selector(buttonSWitchSelector(sender:)), for: .touchUpInside)
        objCell.buttonNotification.tag = indexPath.item
        objCell.selectionStyle = .none
        return objCell
    }
    @IBAction func buttonSWitchSelector(sender:UIButton){
        
        if self.arrayOfNotificationSetting.count > sender.tag{
            let objNotification = self.arrayOfNotificationSetting[sender.tag]
            self.updateParentNotificationSetting(id: objNotification.id, status: objNotification.objStatus)
        }
        /*
        if self.objSelectedSet.contains(sender.tag){
            self.objSelectedSet.remove(sender.tag)
        }else{
            self.objSelectedSet.add(sender.tag)
        }
        DispatchQueue.main.async {
            self.tableViewNotification.reloadData()
        }*/
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0//UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objCountry = self.arrayOfNotification[indexPath.row]
        
    }
    
}
struct NotificationSetting {
    var objStatus,name,defaultStatus,id:String
}
