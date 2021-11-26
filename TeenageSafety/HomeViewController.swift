//
//  HomeViewController.swift
//  TeenageSafety
//
//  Created by user on 04/10/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreBluetooth

class HomeViewController: UIViewController,CBCentralManagerDelegate {

    
    @IBOutlet var buttonSpeedMonitoring:UIButton!
    @IBOutlet var buttonOBD:UIButton!
    @IBOutlet var buttonOBDBLE:UIButton!
    @IBOutlet var lblBatteryLevel:UILabel!
    @IBOutlet var buttonMap:UIButton!
    
    var centralManager:CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        // Do any additional setup after loading the view.
        self.addBorderOnUIButton(objButton: buttonOBD)
        self.addBorderOnUIButton(objButton: buttonSpeedMonitoring)
        self.addBorderOnUIButton(objButton: buttonOBDBLE)
        self.addBorderOnUIButton(objButton: buttonMap)
        self.checkForBlueTooth()
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let strBattery = String(format: "%.0f%%", batteryLevel * 100)
        DispatchQueue.main.async {
            self.lblBatteryLevel.text = "\(strBattery)"
            //ShowToast.shorw(toatMessage: "\(strBattery)")
        }
    }
    
    // MARK: - Custom Methods
    func checkForBlueTooth(){
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    func addBorderOnUIButton(objButton:UIButton){
        objButton.layer.borderWidth = 0.7
        objButton.layer.borderColor = objButton.tintColor.cgColor
        objButton.clipsToBounds = true
    }
    
    // MARK: - Selector Methods
    @IBAction func buttonOBDSelector(sender:UIButton){
        if let objOBDViewController = self.storyboard?.instantiateViewController(withIdentifier: "OBDViewController") as? OBDViewController{
            self.navigationController?.pushViewController(objOBDViewController, animated: true)
        }
    }
    @IBAction func buttonSpeedMonitoringSelector(sender:UIButton){
        if let objSpeedMonitoring = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController{
            self.navigationController?.pushViewController(objSpeedMonitoring, animated: true)
        }
    }
    @IBAction func buttonOBDBLESelector(sender:UIButton){
        if let objOBDBLE = self.storyboard?.instantiateViewController(withIdentifier: "OBD2ViewController") as? OBD2ViewController{
            self.navigationController?.pushViewController(objOBDBLE, animated: true)
        }
    }
    @IBAction func buttonMapSelector(sender:UIButton){
        if let objTabController = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as? HomeTabBarViewController{
            objTabController.selectedIndex = 0
            self.navigationController?.pushViewController(objTabController, animated: false)
        }
        /*
        if let objMapView = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController{
            self.openBluetooth()
            //self.navigationController?.pushViewController(objMapView, animated: true)
        }*/
    }
    func openBluetooth(){
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            // Handling errors that should not happen here
            return
        }
        let app = UIApplication.shared
        app.open(url)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
