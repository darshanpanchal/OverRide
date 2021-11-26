//
//  ChildConnectODBViewController.swift
//  TeenageSafety
//
//  Created by user on 30/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreBluetooth
import ExternalAccessory

class ChildConnectODBViewController: UIViewController,CBCentralManagerDelegate {

    @IBOutlet var tableViewOBDDevice:UITableView!
    
    var manager: CBCentralManager? = nil

    var peripherals = [CBPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    override func viewDidAppear(_ animated: Bool) {
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    // MARK: - Custom Methods
    func setup(){
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.global())

        //configure TableView
        self.configureTableView()
        
        let objAccessoryList = EAAccessoryManager.shared().connectedAccessories

        print(objAccessoryList)
        
    }
    //configure Tableview
    func configureTableView(){
        self.tableViewOBDDevice.delegate = self
        self.tableViewOBDDevice.dataSource = self
        self.tableViewOBDDevice.reloadData()
        
    }
    // MARK: - API Request Methods
    func obdConnectionAPIRequest(objCBPeripheral:CBPeripheral){
        let childOBDConnectParameters:[String:Any] = ["obd":"\(objCBPeripheral.identifier)"]
       
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kChildOBDConnect, parameter: childOBDConnectParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                if var objChild:Child = Child.getChildFromUserDefault(){
                    objChild.obdID = "\(objCBPeripheral.identifier)"
                    objChild.setchildDetailToUserDefault()
                }
                self.childBluetoothConnectionAPIRequest(isConnected: true)
                self.dismiss(animated: true, completion: nil)
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
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kChildBLEConnect, parameter: childBLEConnectionParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
        }) { (responseFail) in
            if let objFail = responseFail as? [String:Any],let message:String = objFail["message"] as? String{
                print(objFail)
                DispatchQueue.main.async {
                    self.view.showToast(message: message, isBlack: false)
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
       peripheral.delegate = self
        if "\(peripheral.name)".contains("OBD") || "\(peripheral.name)".contains("obd"){
            manager?.connect(peripheral, options: nil)
        }
        if var objChild:Child = Child.getChildFromUserDefault(){
            if objChild.obdID == "\(peripheral.identifier)"{
                manager?.connect(peripheral, options: nil)
            }
        }
        
        let filter = self.peripherals.filter({$0.name == peripheral.name})
        if !peripherals.contains(peripheral) && filter.count == 0{
            let localName = advertisementData[CBAdvertisementDataLocalNameKey]
            if localName != nil{
                print("\(String(describing: localName))" )
                
                peripherals.append(peripheral)
                DispatchQueue.main.async {
                    self.tableViewOBDDevice.reloadData()
                }
                
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("didConnect \(peripheral)")
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        
            //self.obdConnectionAPIRequest(objCBPeripheral: peripheral)
        
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            print("didDisconnectPeripheral \(peripheral.name)")
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
           print("didFailToConnect \(peripheral)")
    }
    
}
extension Data{
func hexEncodedString() -> String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(count * 2)

        for byte in self {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.insert(hexDigits[index2], at: 0)
            hexChars.insert(hexDigits[index1], at: 0)
        }
        return String(utf16CodeUnits: hexChars, count: hexChars.count)
    }
}
extension String {
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
}
extension ChildConnectODBViewController:CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor characteristic")
        
        DispatchQueue.main.async {
            ShowToast.show(toatMessage: "didUpdateValueFor characteristic")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices \(peripheral.name)")
        DispatchQueue.main.async {
            ShowToast.show(toatMessage: "didDiscoverServices")
        }
    }
       func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            print("didDiscoverCharacteristicsFor")
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "didDiscoverCharacteristicsFor")
            }
        }
    
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
           print("didWriteValueFor descriptor")
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "didWriteValueFor descriptor")
               }
       }
       func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
           print("didWriteValueFor characteristic")
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "didWriteValueFor characteristic")
            }
       }
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        DispatchQueue.main.async {
            ShowToast.show(toatMessage: "didReadRSSI")
         }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "didDiscoverIncludedServicesFor")
                }
        
    }
    func didReadValueForCharacteristic(_ characteristic: CBCharacteristic) {
                if let mac_address = characteristic.value?.hexEncodedString().uppercased(){
                let macAddress = mac_address.separate(every: 2, with: ":")
                print("MAC_ADDRESS: \(macAddress)")
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(macAddress)")
                    }
            }
    }
}
extension ChildConnectODBViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "ChildBLEDeviceTableViewCell") as! ChildBLEDeviceTableViewCell
        let peripheral = peripherals[indexPath.row]
        objCell.lblDeviceName.text = peripheral.name
        objCell.lblDeviceID.text =  "\(peripheral.identifier)"
        
        
        return objCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDevice = self.peripherals[indexPath.row]
        switch selectedDevice.state {
        case .disconnected:
            print("\(selectedDevice.name) Peripheral state: disconnected")
        case .connected:
            print("\(selectedDevice.name)  Peripheral state: connected")
        case .connecting:
            print("\(selectedDevice.name)  Peripheral state: connecting")
        case .disconnecting:
            print("\(selectedDevice.name) Peripheral state: disconnecting")
        }
        manager?.connect(selectedDevice)
        
        /*
        if let deviceName = selectedDevice.name,deviceName.contains("Mi"){
            manager?.connect(selectedDevice)
        }else{
            DispatchQueue.main.async {
//                self.view.showToast(message: "Please select OBD", isBlack: true)
            }
        }*/
       
    }
}
class ChildBLEDeviceTableViewCell: UITableViewCell {
    
    @IBOutlet var imgDevice:UIImageView!
    @IBOutlet var lblDeviceName:UILabel!
    @IBOutlet var lblDeviceID:UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
