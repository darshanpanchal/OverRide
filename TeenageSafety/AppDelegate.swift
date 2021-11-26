//
//  AppDelegate.swift
//  TeenageSafety
//
//  Created by user on 18/09/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import OBD2_BLE
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import UserNotifications
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,UNUserNotificationCenterDelegate, MessagingDelegate{

    var window: UIWindow?
    var timer = Timer()
    var currentChildID:String?
    
    var isSprint1Only:Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
      
        IQKeyboardManager.shared.enable = true
//        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        //AIzaSyAj5_bGTDX81RiYFaB6EEbauNC43r25xoM
       GMSServices.provideAPIKey("AIzaSyDTmuVmkW5Hgih7nxKN-abM41GlY36nPIc")
       GMSPlacesClient.provideAPIKey("AIzaSyDTmuVmkW5Hgih7nxKN-abM41GlY36nPIc")
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
  
        UITabBar.appearance().tintColor = kThemeColor
        UITabBar.appearance().unselectedItemTintColor = UIColor.init(hexString: "#363636")
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().shadowImage = UIImage()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#363636")], for: .normal)
       
        if let currentChildID:String =  UserDefaults.standard.value(forKey: "currentChild") as? String{
            self.currentChildID = currentChildID
        }
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        application.applicationIconBadgeNumber = 0
        
        UITabBar.appearance().barTintColor = UIColor.white // your color


        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("applicationWillResignActive")
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(token, forKey: "currentDeviceToken")
        UserDefaults.standard.synchronize()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
//            print("time \(Date())")
//        }
        //self.runTimer()
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "currentDeviceToken")
        UserDefaults.standard.synchronize()
        let dataDict:[String: String] = ["token": fcmToken]
        // TODO: If necessary send token to application server.
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent")
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didReceive")
    }
    func runTimer() {
         Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_ ) in
            print("\(Date())")
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "\(Date())")
            }
        })
        //timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer(){
        print("\(Date())")
        DispatchQueue.main.async {
            ShowToast.show(toatMessage: "\(Date())")
        }
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
      //  self.perform(#selector(self.delayedPermissionCheck), with: nil, afterDelay: 5.0)

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate")

    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       print("performFetchWithCompletionHandler")
    }
    func getTopViewController() -> UINavigationController {
        
        var viewController = UINavigationController()
        
        if let vc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            viewController = vc
            var presented = vc
            while let top = presented.presentedViewController {
                presented = UINavigationController.init(rootViewController: top)
                viewController = UINavigationController.init(rootViewController: top)
            }
        }
        
        return viewController
        
    }
    @objc func delayedPermissionCheck() {
        PermissionCheck.checkPermissions()
    }

}

