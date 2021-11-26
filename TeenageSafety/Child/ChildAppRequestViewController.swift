//
//  ChildAppRequestViewController.swift
//  TeenageSafety
//
//  Created by user on 10/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ChildAppRequestViewController: UIViewController {

    @IBOutlet var tableViewChildAppList:UITableView!
    
    var arrayApp:[ApplicationJSON] = []
    var childGETApplication:[[String:Any]] = []
    var currentChild:Child?
   
    @IBOutlet var buttonSOS:RoundButton!
    
    var locationManager: CLLocationManager!

    var lastLocation:CLLocation?
    
    var manager: CBCentralManager? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getChildApplicationAPIRequest()
        self.checkForLocation()
        
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
        
    }
    override func viewDidAppear(_ animated: Bool) {
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    fileprivate func setup() {
        
        self.configureTableView()
    }
    
    // MARK: - Setup
    func checkForLocation(){
        if (CLLocationManager.locationServicesEnabled()){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    func configureTableView(){
        self.tableViewChildAppList.allowsSelection = true
        self.tableViewChildAppList.delegate = self
        self.tableViewChildAppList.dataSource = self
        self.tableViewChildAppList.reloadData()
    }

    // MARK: - App Request
    func getChildApplicationAPIRequest(){
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: kChildGETApplication, parameter:nil, isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [[String:Any]]{
                self.childGETApplication = successData
                self.arrayApp.removeAll()
                for var objJSON in successData{
                    if var statusJSON = objJSON["status"] as? [String:Any]{
                        statusJSON.updateJSONToString()
                        if let objStatusJSON = statusJSON as? [String:String]{
                            let objAppJSON = ApplicationJSON.init(appID: "\(objJSON["app_id"] ?? "")", imageURL: "\(objJSON["image_url"] ?? "")", name: "\(objJSON["name"] ?? "")", device_type: "\(objJSON["device_type"] ?? "")", isLock: "\(objStatusJSON["isLocked"] ?? "")", isSysApp: "\(objStatusJSON["isSysApp"] ?? "")", isRequested: "\(statusJSON["isRequested"] ?? "")") //isRequested
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
    func requestChildSOSAPI(){
        var childSosParameters:[String:Any] = [:]
        if let lastLocation = self.lastLocation{
            childSosParameters["latitude"] = "\(lastLocation.coordinate.latitude)"
            childSosParameters["longitude"] = "\(lastLocation.coordinate.longitude)"
        }
        
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kChildSOS, parameter:childSosParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    self.view.showToast(message: message, isBlack: true)
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
                    let objAppJSON = ApplicationJSON.init(appID: "\(objJSON["app_id"] ?? "")", imageURL: "\(objJSON["image_url"] ?? "")", name: "\(objJSON["name"] ?? "")", device_type: "\(objJSON["device_type"] ?? "")", isLock: "\(objStatusJSON["isLocked"] ?? "")", isSysApp: "\(objStatusJSON["isSysApp"] ?? "")", isRequested: "\(statusJSON["isRequested"] ?? "")") //
                    self.arrayApp.append(objAppJSON)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableViewChildAppList.reloadData()
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonProfileSelector(sender:UIButton){
        self.pushToChildViewController()
    }
    @IBAction func buttonSOSSelector(sender:UIButton){
        self.requestChildSOSAPI()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToChildViewController(){
        if let objChildProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildProfileViewController") as? ChildProfileViewController{
            objChildProfileViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objChildProfileViewController, animated: true)
        }
    }

}

extension ChildAppRequestViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayApp.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "ChildAppListTableViewCell") as! ChildAppListTableViewCell
        let objJSON = arrayApp[indexPath.row]
        objCell.selectionStyle = .none
        let objURL = URL.init(string:objJSON.imageURL)
       // objCell.buttonApp!.sd_setImage(with: objURL, for: .normal, placeholderImage: (objJSON.device_type == "android") ? UIImage.init(named: "andro") : UIImage.init(named: "appl") , options: .refreshCached, progress: nil, completed: nil)
        objCell.buttonLock.addTarget(self, action: #selector(buttonAppRequestSelector(sender:)), for: .touchUpInside)
        objCell.lblAppName.text = objJSON.name
        objCell.buttonLock.tag = indexPath.row
        if (objJSON.isRequested == "true") {
            objCell.buttonLock.backgroundColor = UIColor.darkGray
        }else{
            objCell.buttonLock.backgroundColor = kThemeColor
        }
        
       // objCell.buttonLock.setImage(objImage, for: .normal)
        return objCell
    }
    @IBAction func buttonAppRequestSelector(sender:UIButton){
        if self.arrayApp.count > sender.tag,self.childGETApplication.count > sender.tag{
            let objJSON = self.arrayApp[sender.tag]
            self.childApplicationRequestAccessAPI(appID: objJSON.appID,tag:sender.tag)

        }
        
        
        
    }
    func childApplicationRequestAccessAPI(appID:String,tag:Int){
        var updateAppRequest:[String:Any] = [:]
        updateAppRequest["app_id"] = appID
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kChildAppAccesss, parameter:updateAppRequest as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    self.reloadLocalJSON(tag: tag)
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
    func reloadLocalJSON(tag:Int){
        if self.arrayApp.count > tag,self.childGETApplication.count > tag{
            
            let objJSON = self.arrayApp[tag]
            var objChildJSON = self.childGETApplication[tag]
            if var statusJSON = objChildJSON["status"] as? [String:Any]{
                statusJSON.updateJSONToString()
                statusJSON["isRequested"] = "true"
                objChildJSON["status"] = statusJSON
            }
            self.childGETApplication.remove(at: tag)
            self.childGETApplication.insert(objChildJSON, at:tag)
            self.reloadApplicationJSON(arrayOfJSON: self.childGETApplication)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0//UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
extension ChildAppRequestViewController:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.lastLocation = locations.last! as CLLocation

    }
}
extension ChildAppRequestViewController:CBCentralManagerDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            manager?.scanForPeripherals(withServices: nil)
        }
        if central.state != .poweredOn{
            self.childBluetoothConnectionAPIRequest(isConnected: false)
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if "\(peripheral.name)".contains("OBD") || "\(peripheral.name)".contains("obd"){
            manager?.connect(peripheral, options: nil)
        }
        if var objChild:Child = Child.getChildFromUserDefault(){
            if objChild.obdID == "\(peripheral.identifier)"{
                manager?.connect(peripheral, options: nil)
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect \(peripheral)")
        self.obdConnectionAPIRequest(objCBPeripheral: peripheral)
        
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral \(peripheral.name)")
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect \(peripheral)")
    }
    
    //OBD API Request Methods
    func obdConnectionAPIRequest(objCBPeripheral:CBPeripheral){
        let childOBDConnectParameters:[String:Any] = ["obd":"\(objCBPeripheral.identifier)"]
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kChildOBDConnect, parameter: childOBDConnectParameters as [String : AnyObject], isHudeShow: false, success: { (responseSuccess) in
            DispatchQueue.main.async {
                if var objChild:Child = Child.getChildFromUserDefault(){
                    objChild.obdID = "\(objCBPeripheral.identifier)"
                    objChild.setchildDetailToUserDefault()
                }
                self.childBluetoothConnectionAPIRequest(isConnected: true)
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
    func childBluetoothConnectionAPIRequest(isConnected:Bool){
        var connection = ""
        if isConnected{
            connection = "connected"
        }else{
            connection = "disconnected"
        }
        let childBLEConnectionParameters:[String:Any] = ["bluetoothconnection":"\(connection)"]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kChildBLEConnect, parameter: childBLEConnectionParameters as [String : AnyObject], isHudeShow: false, success: { (responseSuccess) in
            
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
