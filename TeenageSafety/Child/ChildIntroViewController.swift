//
//  ChildIntroViewController.swift
//  TeenageSafety
//
//  Created by user on 02/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CHIPageControl
import CoreBluetooth
import CoreLocation
import UserNotifications


class ChildIntroViewController: UIViewController {

    @IBOutlet var objPage:CHIPageControlAji!
    @IBOutlet var buttonNext:UIButton!
    
    @IBOutlet var lblName:UILabel!
    @IBOutlet var txtDetail:UITextView!
    @IBOutlet var objImage:UIImageView!
    
    
    var locationManager = CLLocationManager()

    var current:Int = 0
    var currentPage:Int{
        get{
          return current
        }
        set{
            current = newValue
            //Configure Update Page
            //self.configureCurrentPage()
            self.checkForApplicatioAccessPermission()
            
        }
    }
    var maximumNumberOfPage:Int = 0
    
    var centralManager:CBCentralManager!

    
    /*var arrayOfPageTitle:[String]  = ["Bluetooth","Draw Overplay","Location","Storage","Notification Capabilities","Mobile Device Management","Override MDM Enrollment"] */
    var arrayOfPageTitle:[String] = ["Bluetooth","Location","Notification Capabilities","Mobile Device Management","Override MDM Enrollment"]
    
    var arrayOfDetailText:[String] = ["OverRIDE is a safety application used to minimize and prevent teens from using their phones while driving our primary focus is creating safe roads while driving and safe driving habits at young age. We hope this will reduce accidents caused by distracted drivers and inevitably save lives.","OverRIDE is a safety application used to minimize and prevent teens from using their phones while driving our primary focus is creating safe roads while driving and safe driving habits at young age. We hope this will reduce accidents caused by distracted drivers and inevitably save lives.","OverRIDE is a safety application used to minimize and prevent teens from using their phones while driving our primary focus is creating safe roads while driving and safe driving habits at young age. We hope this will reduce accidents caused by distracted drivers and inevitably save lives.","OverRIDE is a safety application used to minimize and prevent teens from using their phones while driving our primary focus is creating safe roads while driving and safe driving habits at young age. We hope this will reduce accidents caused by distracted drivers and inevitably save lives.","OverRIDE is a safety application used to minimize and prevent teens from using their phones while driving our primary focus is creating safe roads while driving and safe driving habits at young age. We hope this will reduce accidents caused by distracted drivers and inevitably save lives.","OverRIDE is a safety application used to minimise and prevent teens from using their phones while driving our primary focus is creating safe roads while driving and safe driving habits at young age. We hope this will reduce accidents caused by distracted drivers and inevitably save lives.","Override user Mobile Device Management (MDM) features to help protect your child's device and provide the content filtering and controls you will apply to your child's device. The next screen will teach you about thease features and the data Override collects to help you manage and protect your family.\nOverride takes your data privacy very seriously."]
    /*
    var arrayOfImagesName:[String] = ["intro_bluetooth","intro_overplay","intro_storage","intro_notification","intro_mobiledevice","intro_mdmentroll","intro_mdmentroll"]
    */
    var arrayOfImagesName:[String] = ["intro_bluetooth","intro_location","intro_notification","intro_mobiledevice","intro_mdmentroll"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view.
        self.setUp()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if locationManager.delegate == nil {
            locationManager.delegate = self
        }
        
    }
    // MARK: - Custom Methods
    func setUp(){
        self.txtDetail.isEditable = false
        self.currentPage = 0
        self.maximumNumberOfPage = self.arrayOfPageTitle.count - 1
        self.objPage.numberOfPages = self.arrayOfPageTitle.count
        self.objPage.progress = Double(self.currentPage)
        self.lblName.font = UIFont.init(name:"Poppins-SemiBold", size: 24.0)!
        self.txtDetail.font = UIFont.init(name:"Poppins-Regular", size: 14.0)!
    }
    func checkForApplicatioAccessPermission(){
        
        if self.currentPage == 1{
            self.checkForBlueTooth()
        }else if self.currentPage == 2{// check for location
            self.checkForLocation()
        }else if self.currentPage == 3{// check for notification
            self.checkForNotificationPermission()
        }else if self.currentPage == 4{// check for MDM
            if let objChild = Child.getChildFromUserDefault(){
                let strURL = "\(kMDMProfileDownloadURL)\(objChild.childId)"
                guard let mdmURL = URL(string: "\(strURL)") else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(mdmURL) {
                      UIApplication.shared.open(mdmURL, completionHandler: { (success) in
                          self.configureCurrentPage()
                      })
                }
            }
            
            
          
        }else if self.currentPage == 5{// check for MDM
            
        }else{
            self.configureCurrentPage()
        }
    }
    func configureCurrentPage(){
        self.objPage.progress = Double(self.currentPage)
        if self.arrayOfPageTitle.count > self.currentPage{
            self.lblName.text = self.arrayOfPageTitle[self.currentPage]
            self.txtDetail.text = self.arrayOfDetailText[self.currentPage]
            if let objImage = UIImage.init(named: self.arrayOfImagesName[self.currentPage]){
                self.objImage.image = objImage
            }
        }
        if self.arrayOfPageTitle.count == self.currentPage+1{
            self.buttonNext.setTitle("Understand Your Privacy", for: .normal)
        }
        
    }
    func checkForBlueTooth(){
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    func checkForLocation(){
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .authorizedWhenInUse  {
            self.presentSettingsAlert(permission: "receive your location even when the app is closed")
        }
        else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    func checkForNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            DispatchQueue.main.async {
                self.configureCurrentPage()
                
            }
        }
    }
    func presentSettingsAlert(permission:String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Permission Denied", message: "You have denied the app permission to \(permission).\n\nTo resolve this issue you have to go to you apps settings and allow the permission manually.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                action in
                alert.dismiss(animated: false, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: {
                action in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        
                    })
                }
                
                
                alert.dismiss(animated: false, completion: nil)
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonNextSelector(sender:UIButton){
        if self.currentPage < maximumNumberOfPage{
            self.currentPage += 1
        }else if self.currentPage == maximumNumberOfPage{ //push to home screen
            //Check for Child MDM acccess and allow child for application
            self.checkForChildMDMAccessandConfigurationAPIRequest()
            //self.pushToChildHomeScreen()
        }
    }
    //Show MDM profile installtion alert
    func showProfileInstallationAlert(){
        /*
        guard UIDevice.current.isSimulator else {
            self.pushToChildHomeScreen()
            return
        }*/
        
        let objAlertViewController = UIAlertController.init(title: "MDM Profile Installation", message: "Please install MDM profile for safe drive with OverRide.", preferredStyle: .alert)
        let installAction = UIAlertAction.init(title: "Install", style: .default) { (_ ) in
            
            
            if let objChild = Child.getChildFromUserDefault(){
                 let strURL = "\(kMDMProfileDownloadURL)\(objChild.childId)"
                 //Open MDM profile installation link
                 guard let mdmURL = URL(string: "\(strURL)") else {
                     return
                 }
                if UIApplication.shared.canOpenURL(mdmURL) {
                              UIApplication.shared.open(mdmURL, completionHandler:nil)
                }
            }
          
          
        }
        objAlertViewController.addAction(installAction)
        self.present(objAlertViewController, animated: true, completion: nil)
        
    }
    // MARK: - API Request Methods
    func checkForChildMDMAccessandConfigurationAPIRequest(){
        //child/mdm/enrollment/status
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: kChildMDMStatus, parameter:nil, isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                if let objSuccess = responseSuccess as? [String:Any],let successData = objSuccess["message"] as? [String:Any]{
                              if let entrolmentStatus = successData["enrollment_status"],"\(entrolmentStatus)" == "installed"{
                                  //Push to home view controller
                                  self.pushToChildHomeScreen()
                              }else{
                                  //Show profile installation alert
                                  self.showProfileInstallationAlert()
                              }
                             
                          }
            }
          
        }) { (responseFail) in
            DispatchQueue.main.async {
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
   
    func pushToChildHomeScreen(){
        
        
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        if let objTabController = mainStoryBoard.instantiateViewController(withIdentifier: "ChildTabBarViewController") as? ChildTabBarViewController{
            objTabController.selectedIndex = 0
//            self.pushToChildOBDConnectionViewController()
            self.navigationController?.pushViewController(objTabController, animated: false)
        }
    }
    func pushToChildOBDConnectionViewController(){
        if let objObdConnectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildConnectODBViewController") as? ChildConnectODBViewController{
            self.navigationController?.pushViewController(objObdConnectionViewController, animated: true)
        }
    }
}
extension ChildIntroViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways:
            self.configureCurrentPage()
            break
        default:
           self.configureCurrentPage()
            break
        }
    }
}
extension ChildIntroViewController:CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn{
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
                self.checkForBlueTooth()
            })
        }
        switch central.state {
            
        case .poweredOn:
            print("Bluetooth is on")
            //print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
            centralManager.scanForPeripherals(withServices: nil,
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
            //move to next page if bluetooth is turn on
            self.configureCurrentPage()
            break
        case .poweredOff:
            print("Bluetooth is Off.")
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        default:
            break
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //print(advertisementData)
        //        print(peripheral.name)
        
        print(advertisementData["CBAdvertisementDataLocalNameKey"])
    }
    
}
