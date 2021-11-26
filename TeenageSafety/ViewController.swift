//
//  ViewController.swift
//  TeenageSafety
//
//  Created by user on 18/09/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import OBD2_BLE
import BlueCapKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController {

    
    lazy var locationManager :CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.allowsBackgroundLocationUpdates = true
        _locationManager.distanceFilter = 1
        _locationManager.activityType = .automotiveNavigation
        return _locationManager
        
    }()
    var locationUpdateCount:Int = 0
    var arrayOfTime:[Date] = []
    @IBOutlet var lblSpeed:UILabel!
    @IBOutlet var lblAccelerometerCount:UILabel!
    @IBOutlet var lblBreakCount:UILabel!
    
    
    
    var lastDate:Date = Date()
    var lastSpeed:Double = 0.0
    var currentAccelerometer:Int = 0
    
    var accelerometerCount:Int{
        get{
            return currentAccelerometer
        }
        set{
            self.currentAccelerometer = newValue
            DispatchQueue.main.async {
                self.lblAccelerometerCount.text = "\(newValue)"
            }
        }
    }
    var currentBreakCount:Int = 0
    var breakCount:Int{
        get{
            return currentBreakCount
        }
        set{
            self.currentBreakCount = newValue
            DispatchQueue.main.async {
                self.lblBreakCount.text = "\(newValue)"
            }
        }
    }
    
    /*
    //location manager
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .AutomotiveNavigation
        _locationManager.distanceFilter = 10.0  // Movement threshold for new events
        //  _locationManager.allowsBackgroundLocationUpdates = true // allow in background
        
        return _locationManager
    }()
    */
    //Shared Instance for OBD
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Speed Monitoring"
        self.updateLocatioUpdate()
        let objMainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        if let objViewController = objMainStoryBoard.instantiateViewController(withIdentifier: "OBD2ViewController") as? OBD2ViewController{
            
            objViewController.updateTime()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func updateLocatioUpdate(){
        //location request and update
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringVisits()
        locationManager.delegate = self
    }
    func obdConnectionAndUpdate(){
        // Do any additional setup after loading the view, typically from a nib.
        let objShared = OBD2_BLE()
        
        let getDeviceID = UIDevice.current.identifierForVendor as? String
        print(getDeviceID)
        //ScanFor Perferal devices
        let manager = CentralManager(options: [CBCentralManagerOptionRestoreIdentifierKey : "us.gnos.BlueCap.central-manager-documentation" as NSString])
        
        let stateChangeFuture = manager.whenStateChanges()
        
        var deviceDetail:[String:Any] = [:]
        deviceDetail["deviceToken"] = ""
        deviceDetail["deviceType"] = "ios"
        deviceDetail["username"] = "admin"
        deviceDetail["password"] = "riken8568"
        print(deviceDetail)
        var bodyDetail:[String:Any] = [:]
        bodyDetail["body"] = deviceDetail
        bodyDetail["method_name"] = "login"
        print(bodyDetail)
        var jsonDetail:[String:Any] = [:]
        jsonDetail["json"] = bodyDetail
        
        do{
            let parameterData = try JSONSerialization.data(withJSONObject:jsonDetail, options:.prettyPrinted)
            let json = try JSONSerialization.jsonObject(with: parameterData, options: .mutableContainers)
            print(json)
            
        }catch{
            
        }
        
        if let objURL = URL.init(string: "http://rangoliapp.com/rangoli_kids/API/1.1/main.php/login"){
            self.callPost(url: objURL, params: jsonDetail,finish: finishPost)
        }
        
        
    }
    
    func finishPost (message:String, data:Data?) -> Void
    {
        do
        {
            if let jsonData = data
            {
                let parsedData = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as! [String: AnyObject]
                print(parsedData)
                let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                print(json)
            }
        }
        catch
        {
            if let data = data, let str = String(data: data, encoding: String.Encoding.utf8){
                print("Server Error: " + str)
            }
            print("Parse Error: \(error)")
        }
    }
    func getPostString(params:[String:Any]) -> String{
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    func callPost(url:URL, params:[String:Any], finish: @escaping ((message:String, data:Data?)) -> Void)
    {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let postString = self.getPostString(params: params)
        
        if let objDate = postString.data(using: .utf8){
            do{
                print(params)
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                
            }
            
            
            
            //request.httpBody = postString.data(using: .utf8)
        }else{
            print("No data Send=======")
        }
        
        
        var result:(message:String, data:Data?) = (message: "Fail", data: nil)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if(error != nil)
            {
                result.message = "Fail Error not null : \(error.debugDescription)"
            }
            else
            {
                result.message = "Success"
                result.data = data
            }
            
            finish(result)
        }
        task.resume()
    }
    
}

extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
     
        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
            print("Lati \(location.coordinate.latitude)")
            print("Alt \(location.altitude)")
            print("Sped \(location.speed)")
            print("Accu \(location.horizontalAccuracy)")
            
            print("**********************")
            
        }
            
        
        if locations.count > 0,let _ = locations.last{
            DispatchQueue.main.async {
                self.locationUpdateCount += 1
                self.arrayOfTime.append(Date())
                let childSpeed = (locations.last!.speed) * (60.0*60.0)/1000.0
                self.lblSpeed.text =  "Location Update with count \(self.locationUpdateCount) \n Speed \(childSpeed) km/h \n Time \(self.arrayOfTime.reversed().last!)"
                //check for break and accelorometer count
                if self.seconds(from: self.lastDate) > 3{
                    print("--------- \(self.seconds(from: self.lastDate))")
                    if childSpeed > self.lastSpeed{
                        if childSpeed - self.lastSpeed > 10.0{
                            self.accelerometerCount += 1
                        }
                    }else {
                        if self.lastSpeed - childSpeed > 10.0{
                            self.breakCount += 1
                        }
                    }
                    
                    self.lastDate = Date()
                    self.lastSpeed = childSpeed
                }
            }
        }
    }
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: Date()).second ?? 0
    }
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // create CLLocation from the coordinates of CLVisit
        let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        
        // Get location description
        self.lblSpeed.text = "\(clLocation.speed)"
    }
    
    func newVisitReceived(_ visit: CLVisit, description: String) {
        print(visit.coordinate)
        print(description)
        //let location = Location(visit: visit, descriptionString: description)
        
        // Save location to disk
    }
}

struct Location{
    let latitude: Double
    let longitude: Double
    let date: Date
    let dateString: String
    let description: String
}
