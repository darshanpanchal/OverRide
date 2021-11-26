//
//  OBD2ViewController.swift
//  TeenageSafety
//
//  Created by user on 04/10/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import OBD2_BLE

class OBD2ViewController: UIViewController {

    @IBOutlet var txtOBDUITextView:UITextView!
    @IBOutlet var lblBackGroundFetch:UILabel!
    
    var obdData = ""
    var currentTime:Date?
    var strTimeData = ""
    var strOBDData:String {
        get{
            return obdData
        }
        set{
            obdData = newValue
            //Update TextField
            DispatchQueue.main.async {
                self.txtOBDUITextView.text = newValue
            }
        }
    }
    var configurationCommands = [
        "ATE0", // Echo Off
        "ATH0", // Headers Off
        "ATS0", // printing of Spaces Off
        "ATL0", // Linefeeds Off
        "ATSP0" // Set Protocol to 0 (Auto)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "OBD BLE"
        // Do any additional setup after loading the view.
        
        self.connectBLEDevice()
        self.configureNavigationBar()
//        self.updateTime()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.strTimeData.count > 0{
            self.lblBackGroundFetch.text = "\(self.strTimeData)"
        }
    }
    // MARK: - Connection Methods
    func updateTime() {
        currentTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if let currentTime = currentTime {
            self.strTimeData = formatter.string(from: currentTime)
        }
    }
    func configureNavigationBar(){
        let objAdd = UIBarButtonItem.init(title: "OBD", style: .plain, target: self, action: #selector(connectBLEDevice))
        self.navigationItem.rightBarButtonItem = objAdd
    }
    @objc func connectBLEDevice(){
        self.strOBDData = "OBD Data :: \n"
          let objOBD =  OBD2_BLE.init()
          objOBD.addConfigurationCommands(commands: configurationCommands)
        DispatchQueue.main.async {
            ShowToast.show(toatMessage: "OBD connected \(objOBD.configureOBD())")
        }
          self.strOBDData += "\n"
          self.strOBDData += "Vin :\t \(objOBD.getVin())\n"
          self.strOBDData += "Speed :\t \(objOBD.getSpeed()) km/h \n"
        //Engine RPM
        objOBD.sendCommandNamed(name: "010C") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Engine RPM :\t \(strRPM) rpm \n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Engine RPM")
                }
            }
        }
        //Engine Run Time
        objOBD.sendCommandNamed(name: "010C") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Engine Run Time :\t \(strRPM) seconds \n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Engine run time")
                }
            }
        }
        //Engine fuel rate 015E
        objOBD.sendCommandNamed(name: "015E") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Engine Fuel rate :\t \(strRPM) L/h\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Engine fuel rate")
                }
            }
        }
        //Distance travel since code cleared 0131
        objOBD.sendCommandNamed(name: "0131") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Distance travel since code cleared :\t \(strRPM) Km\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Distance since code cleared")
                }
            }
        }
        //Distance traveled with malfunction indicator lamp (MIL) on 0121
        objOBD.sendCommandNamed(name: "0121") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Distance traveled with malfunction indicator lamp (MIL) on :\t \(strRPM) Km\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Distance with MIL on")
                }
            }
        }
        //Intake manifold absolute pressure 010B
        objOBD.sendCommandNamed(name: "010B") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Intake manifold absolute pressure :\t \(strRPM) kPa\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Intake manifold absolute pressure")
                }
            }
        }
        //Intake air temperature 010F
        objOBD.sendCommandNamed(name: "010F") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Intake air temperature :\t \(strRPM) °C\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Intake air temperature")
                }
            }
        }
        //Fuel pressure 010A
        objOBD.sendCommandNamed(name: "010A") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Fuel pressure :\t \(strRPM) Kpa\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Fuel pressure")
                }
            }
        }
        //Engine Coolant Temp
        objOBD.sendCommandNamed(name: "0105") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Engine Coolant temp : \t \(strRPM) °C\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Engine Coolant Temp")
                }
            }
        }
        //Engine load
        objOBD.sendCommandNamed(name: "0104") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Engine Load \t \(strRPM) %\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Engine load")
                }
            }
        }
        //Engine oil temperature    015C
        objOBD.sendCommandNamed(name: "015C") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Engine oil temp : \t \(strRPM) °C\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Engine Oil Temp")
                }
            }
        }
        //Absolute Barometric Pressure    0133
        objOBD.sendCommandNamed(name: "0133") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Absolute Barometric Pressure : \t \(strRPM) kPa\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Absolute Barometric Pressure")
                }
            }
        }
        
//          objOBD.getVehicleInfo(vinNumber: "\(objOBD.getVin())") { (info) in
//              self.strOBDData += "Vehicle Detail \n \(info)\n"
//          }
        
        
        //Engine Vin Number
        objOBD.sendCommandNamed(name: "0902") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Engine Coolant temp \t \(strRPM)\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Engine Vin")
                }
            }
        }
        //Fuel Type
        objOBD.sendCommandNamed(name: "0151") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Fuel Type \t \(strRPM)\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Fuel Type")
                }
            }
        }
        //Fuel Level
        objOBD.sendCommandNamed(name: "012F") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Fuel Level \t \(strRPM) %\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Fuel level")
                }
            }
        }
        //Driving Duration
        objOBD.sendCommandNamed(name: "017F") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Drive Duration \t \(strRPM)\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Driving duration")
                }
            }
        }
        //Battery Life
        objOBD.sendCommandNamed(name: "015B") { dataArray in
            if let strRPM = String(bytes: dataArray, encoding: .utf8) {
                self.strOBDData += "Battery pack remaining life \t \(strRPM)\n"
            } else {
                print("not a valid UTF-8 sequence")
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "UTF Error on Battery pack remaining life")
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
    

}
