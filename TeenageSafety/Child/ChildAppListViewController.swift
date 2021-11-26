//
//  ChildAppListViewController.swift
//  TeenageSafety
//
//  Created by user on 10/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ChildAppListViewController: UIViewController {

    @IBOutlet var tableViewChildAppList:UITableView!
    
    var arrayOfNotificationSetting:[String] = []
    
    var childGETApplication:[[String:Any]] = []
    var arrayApp:[ApplicationJSON] = []
    var currentChild:Child?

    var childUPDATEApplication:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let objChild = self.currentChild{
            self.getNotificationAPIRequest(id: objChild.childId)
        }
        self.configureTableView()
    }
    func configureTableView(){
        self.tableViewChildAppList.allowsSelection = true
        self.tableViewChildAppList.delegate = self
        self.tableViewChildAppList.dataSource = self
        self.tableViewChildAppList.reloadData()
    }
     // MARK: - API Request
    func getNotificationAPIRequest(id:String){
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentGETChildApplication, parameter:["id":"\(id)" as AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [[String:Any]]{
                self.arrayOfNotificationSetting.removeAll()
                self.childGETApplication = successData
                self.arrayApp.removeAll()
                for var objJSON in successData{
                        if var statusJSON = objJSON["status"] as? [String:Any]{
                            statusJSON.updateJSONToString()
                            if let objStatusJSON = statusJSON as? [String:String]{
                                let objAppJSON = ApplicationJSON.init(appID: "\(objJSON["app_id"] ?? "")", imageURL: "\(objJSON["image_url"] ?? "")", name: "\(objJSON["name"] ?? "")", device_type: "\(objJSON["device_type"] ?? "")", isLock: "\(objStatusJSON["isLocked"] ?? "")", isSysApp: "\(objStatusJSON["isRequested"] ?? "")", isRequested: "\(statusJSON["isSysApp"] ?? "")")
                                self.arrayApp.append(objAppJSON)
                            }
                    }
                }
                DispatchQueue.main.async {
                    self.tableViewChildAppList.reloadData()
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
    func reloadApplicationJSON(arrayOfJSON:[[String:Any]]){
        self.arrayApp.removeAll()
        for var objJSON in arrayOfJSON{
            if var statusJSON = objJSON["status"] as? [String:Any]{
                statusJSON.updateJSONToString()
                if let objStatusJSON = statusJSON as? [String:String]{
                    let objAppJSON = ApplicationJSON.init(appID: "\(objJSON["app_id"] ?? "")", imageURL: "\(objJSON["image_url"] ?? "")", name: "\(objJSON["name"] ?? "")", device_type: "\(objJSON["device_type"] ?? "")", isLock: "\(objStatusJSON["isLocked"] ?? "")", isSysApp: "\(objStatusJSON["isRequested"] ?? "")", isRequested: "\(statusJSON["isSysApp"] ?? "")")
                    self.arrayApp.append(objAppJSON)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableViewChildAppList.reloadData()
        }
    }
    func updateChildRequestAccessPermission(){
        var updateChildParameters:[String:Any] = [:]
        if let _ = self.currentChild{
            updateChildParameters["id"] = self.currentChild!.childId
        }
        updateChildParameters["data"] = self.childGETApplication
        updateChildParameters["notification_id"] = ""
        updateChildParameters["notification_type"] = "update"
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentChildAppAccess, parameter:updateChildParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    if let keyWindow = UIApplication.shared.keyWindow{
                        keyWindow.showToast(message: message, isBlack: true)
                    }
                    self.navigationController?.popViewController(animated: true)
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
    @IBAction func buttonUpdateRequestAccess(sender:UIButton){
        self.updateChildRequestAccessPermission()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension ChildAppListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayApp.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "ChildAppListTableViewCell") as! ChildAppListTableViewCell
        let objJSON = arrayApp[indexPath.row]
        objCell.selectionStyle = .none
        let objURL = URL.init(string:objJSON.imageURL)
        objCell.buttonApp!.sd_setImage(with: objURL, for: .normal, placeholderImage: (objJSON.device_type == "android") ? UIImage.init(named: "andro") : UIImage.init(named: "appl") , options: .refreshCached, progress: nil, completed: nil)
        objCell.buttonLock.addTarget(self, action: #selector(buttonAppRequestSelector(sender:)), for: .touchUpInside)
        objCell.lblAppName.text = objJSON.name
        objCell.buttonLock.tag = indexPath.row
        let objImage = (objJSON.isLock == "true") ? UIImage.init(named: "lock_app"):UIImage.init(named: "unlock_app")
        objCell.buttonLock.setImage(objImage, for: .normal)
        return objCell
    }
    @IBAction func buttonAppRequestSelector(sender:UIButton){
        
        if self.arrayApp.count > sender.tag,self.childGETApplication.count > sender.tag{
             let objJSON = self.arrayApp[sender.tag]
             var objChildJSON = self.childGETApplication[sender.tag]
            if var statusJSON = objChildJSON["status"] as? [String:Any]{
                statusJSON.updateJSONToString()
                if ("\(statusJSON["isLocked"] ?? "")" == "true"){
                    statusJSON["isLocked"] = "false"
                }else{
                    statusJSON["isLocked"] = "true"
                }
                objChildJSON["status"] = statusJSON
            }
            self.childGETApplication.remove(at: sender.tag)
            self.childGETApplication.insert(objChildJSON, at: sender.tag)
            self.reloadApplicationJSON(arrayOfJSON: self.childGETApplication)
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0//UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
class ChildAppListTableViewCell:UITableViewCell{
    
    @IBOutlet var buttonApp:RoundCornerButton!
    @IBOutlet var lblAppName:UILabel!
    @IBOutlet var buttonLock:UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonLock.imageView?.contentMode = .scaleAspectFit
    }
}
struct ApplicationJSON {
    var appID, imageURL, name, device_type:String
    var isLock, isSysApp, isRequested:String
}

