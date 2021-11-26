//
//  PermissionViewController.swift
//  TeenageSafety
//
//  Created by user on 12/11/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications
import Photos
import CoreLocation

class PermissionViewController: UIViewController,CLLocationManagerDelegate{

    @IBOutlet var lblCameraAccess:UILabel!
    @IBOutlet var objCameraSwitch:UISwitch!
    @IBOutlet var swPhotoLibrary : UISwitch!
    @IBOutlet var swLocation : UISwitch!
    @IBOutlet var swPushNotifications : UISwitch!
    
    var locationManager = CLLocationManager()
    var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        
        loaded = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: NSNotification.Name(Notification.REFRESH_PERMISSIONS), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if locationManager.delegate == nil {
            locationManager.delegate = self
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways:
            updateUI()
            break
        default:
            self.presentSettingsAlert(permission: "receive your location even when the app is closed")
            self.updateUI()
            break
        }
    }
    @objc func updateUI(){
        
        var allGranted = true;
        
        
        //Camera Access
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            objCameraSwitch.isOn = true
            objCameraSwitch.isUserInteractionEnabled = false
        }
        else {
            objCameraSwitch.isUserInteractionEnabled = true
            objCameraSwitch.isOn = false
            allGranted = false
        }
        
        //Library Access
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            swPhotoLibrary.isOn = true
            swPhotoLibrary.isUserInteractionEnabled = false
        }
        else {
            swPhotoLibrary.isUserInteractionEnabled = true
            swPhotoLibrary.isOn = false
            allGranted = false
        }
        
        
        
        
        
        
        //Location
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                swLocation.isOn = true
                swLocation.isUserInteractionEnabled = false
            }
            else {
                swLocation.isUserInteractionEnabled = true
                swLocation.isOn = false
                allGranted = false
            }
        }else {
            swLocation.isUserInteractionEnabled = true
            swLocation.isOn = false
            allGranted = false
        }
        
        
        //Remote Notifications
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) in
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                
                if settings.authorizationStatus == .authorized {
                    self.swPushNotifications.isOn = true
                    self.swPushNotifications.isUserInteractionEnabled = false
                }else {
                    self.swPushNotifications.isUserInteractionEnabled = true
                    self.swPushNotifications.isOn = false
                    allGranted = false
                }
                if allGranted {
                    //
                    NotificationCenter.default.removeObserver(self)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func getCameraAccess() {
        self.view.isUserInteractionEnabled = false
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
            granted in
            DispatchQueue.main.async {
                self.updateUI()
                if !granted {
                    self.presentSettingsAlert(permission: "the devices camera")
                }
                
            }
        })
    }
    @IBAction func getLibraryAccess() {
        
        self.view.isUserInteractionEnabled = false
        PHPhotoLibrary.requestAuthorization({
            status in
            
            DispatchQueue.main.async {
                self.updateUI()
                if status != PHAuthorizationStatus.authorized {
                    self.presentSettingsAlert(permission: "the devices photo library")
                }
            }
        })
        
    }
    @IBAction func getFullLocationAccess() {
        
        self.view.isUserInteractionEnabled = false
        
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .authorizedWhenInUse  {
            self.presentSettingsAlert(permission: "receive your location even when the app is closed")
            self.updateUI()
        }
        else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    @IBAction func getPushNotificationAccess() {
        
        self.view.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                DispatchQueue.main.async {
                    self.updateUI()
                    /*
                     if !granted {
                     self.presentSettingsAlert(permission: "send you push notifications")
                     }
                     else {
                     self.updateUI()
                     }*/
                    
                }
            }
        }
        
    }
    func presentSettingsAlert(permission:String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Permission Denied", message: "You have denied the app permission to \(permission).\n\nTo resolve this issue you have to go to you apps settings and allow the permission manually.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                action in
                self.updateUI()
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

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
class PermissionCheck: NSObject {
    
    static func checkPermissions() {
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) !=  AVAuthorizationStatus.authorized {
            self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
            return
        }
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
            return
        }
        
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
                return
            }
        }else {
            self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
        }
        /*
        if AVAudioSession.sharedInstance().recordPermission != .granted {
            self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
            return
        }*/
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    self.perform(#selector(self.showPermissionView), with: nil, afterDelay: 0.3)
                    return
                }
            }
        })
    }
    
    @objc static func showPermissionView() {
        DispatchQueue.main.async {
            let vc = (UIApplication.shared.delegate as! AppDelegate).getTopViewController()
            
            if vc.viewControllers.count > 0 ,vc.viewControllers.last! is PermissionViewController{
                NotificationCenter.default.post(name: NSNotification.Name(Notification.REFRESH_PERMISSIONS), object: nil, userInfo: nil)
                return
            }
            
            if vc.viewControllers.count > 0 ,vc.viewControllers.last! is UIAlertController{
                let presenting = vc.presentingViewController!
                
                if presenting is PermissionViewController {
                    NotificationCenter.default.post(name: NSNotification.Name(Notification.REFRESH_PERMISSIONS), object: nil, userInfo: nil)
                    return
                }
                
                vc.dismiss(animated: false, completion: {
                    
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let permVC = sb.instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
                    presenting.present(permVC, animated: true, completion: nil)
                    
                })
                
            }
            else {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let permVC = sb.instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
                vc.present(permVC, animated: true, completion: nil)
            }
            
            
        }
        
    }
}
