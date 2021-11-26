//
//  ChildSummaryViewController.swift
//  TeenageSafety
//
//  Created by user on 20/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import SDWebImage
import CoreBluetooth

class ChildSummaryViewController: UIViewController {

    
    @IBOutlet var lblWeekDate:UILabel!
    @IBOutlet var lblWeekDetail:UILabel!
    @IBOutlet var buttonProfile:UIButton!
    @IBOutlet var buttonCalendar:UIButton!
    
    @IBOutlet var buttonLeft:UIButton!
    @IBOutlet var buttonRight:UIButton!
    
    
    @IBOutlet var collectionViewChild:UICollectionView!
    
    @IBOutlet var tableViewSummary:UITableView!
    
    var currentDate = Date()
    var dateFormate = DateFormatter()

    var currentChild:Child?    
    var currentChildAVGSummary:AVGSummary?
    
    var staticData:[SummaryStatic] = []
    var arrayOfWeeklyChildSummary:[ChildSummary] = []
    
    var manager: CBCentralManager? = nil
    @IBOutlet var txtDateTextField:UITextField!
    var fromDatePicker:UIDatePicker = UIDatePicker()
    var fromDatePickerToolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
        //register child device udid to MDM server
        //self.registerChildDeviceUDIDAPIRequest()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //present near by device if blank on child login
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
//        
//        if self.checkForChildFirstTimeConfiguration(){
//            self.pushToChildOBDConnectionViewController()
//        }
        self.checkForChildMDMAccessandConfigurationAPIRequest()
    }
    //Show MDM profile installtion alert
    func showProfileInstallationAlert(){
        
        guard !UIDevice.current.isSimulator else {
           
            return
        }
        
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.txtDateTextField.resignFirstResponder()
            self.view.endEditing(true)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    func checkForChildFirstTimeConfiguration()->Bool{
        if let currentChild = Child.getChildFromUserDefault(){
            return currentChild.obdID.count == 0
        }
        return  false
    }
    // MARK: - Setup Methods
    func setup(){
        self.dateFormate.dateFormat = "dd MMM YYYY"
        self.getExpenseTrail(strDates: self.getCurrentWeekDate())
        self.buttonProfile.imageView?.contentMode = .scaleAspectFit
//        self.buttonCalendar.imageView?.contentMode = .scaleAspectFit
        self.configureTableView()
        self.configureCollectionView()
        
        if let objChild:Child = Child.getChildFromUserDefault(){
            self.currentChild = objChild
            
        }
        self.configureStaticDate()
        
        self.configureFormDatePicker()
    }
    func configureTableView(){
        //ParentChildSummaryTableViewCell
        let objNib = UINib.init(nibName: "ParentChildSummaryTableViewCell", bundle: nil)
        self.tableViewSummary.register(objNib, forCellReuseIdentifier: "ParentChildSummaryTableViewCell")
        self.tableViewSummary.delegate = self
        self.tableViewSummary.dataSource = self
        self.tableViewSummary.reloadData()
        self.tableViewSummary.allowsSelection = true
        self.tableViewSummary.layoutIfNeeded()
    }
    func configureCollectionView(){
        let objNib = UINib.init(nibName: "ChildSummaryCollectionViewCell", bundle: nil)
        self.collectionViewChild.register(objNib, forCellWithReuseIdentifier: "ChildSummaryCollectionViewCell")
        self.collectionViewChild.delegate = self
        self.collectionViewChild.dataSource = self
        self.collectionViewChild.reloadData()
        self.collectionViewChild.allowsSelection = false
        self.collectionViewChild.layoutIfNeeded()
    }
    func configureStaticDate(){
        self.staticData.append(SummaryStatic.init(day: "Sun", date: "08 Dec 2019", percentage: "60 %", overspeed: "6", harshbreak: "3", rapid: "6", ideal: "5"))
        self.staticData.append(SummaryStatic.init(day: "Mon", date: "09 Dec 2019", percentage: "64 %", overspeed: "7", harshbreak: "5", rapid: "7", ideal: "6"))
        self.staticData.append(SummaryStatic.init(day: "Tue", date: "10 Dec 2019", percentage: "70 %", overspeed: "5", harshbreak: "4", rapid: "6", ideal: "5"))
        self.staticData.append(SummaryStatic.init(day: "Wed", date: "11 Dec 2019", percentage: "50 %", overspeed: "6", harshbreak: "3", rapid: "5", ideal: "2"))
        self.staticData.append(SummaryStatic.init(day: "Thurs", date: "12 Dec 2019", percentage: "66 %", overspeed: "4", harshbreak: "2", rapid: "3", ideal: "3"))
        self.staticData.append(SummaryStatic.init(day: "Fri", date: "13 Dec 2019", percentage: "55 %", overspeed: "2", harshbreak: "5", rapid: "2", ideal: "4"))
        self.staticData.append(SummaryStatic.init(day: "Sat", date: "14 Dec 2019", percentage: "72 %", overspeed: "7", harshbreak: "6", rapid: "6", ideal: "5"))
        
        self.tableViewSummary.reloadData()
        
    }
    func getCurrentWeekDate()->[String]{
        var dates : [String] = []
        if let endDate = Calendar.current.date(byAdding: .day, value: -6, to: self.currentDate){
            
            let strEndDate = self.dateFormate.string(from: endDate)
            dates.append(strEndDate)
            let strStartDate = self.dateFormate.string(from: self.currentDate)
            dates.append(strStartDate)
            return dates
        }
        
        return []
    }
    func getPreviousWeekDate(fromDate:Date)->[String]{
        var dates : [String] = []
        
        if let startDate = Calendar.current.date(byAdding: .day, value: -6, to: self.currentDate){
            let strStartDate = self.dateFormate.string(from: startDate)
            dates.append(strStartDate)
            let strEndDate = self.dateFormate.string(from: self.currentDate)
            dates.append(strEndDate)
            
            return dates
        }
        return []
    }
    func getNextWeekDate(fromDate:Date)->[String]{
        var dates : [String] = []
        
        if let endDate = Calendar.current.date(byAdding: .day, value: 6, to: self.currentDate){
            let strStartDate = self.dateFormate.string(from: self.currentDate)
            dates.append(strStartDate)
            let strEndDate = self.dateFormate.string(from: endDate)
            dates.append(strEndDate)
            self.currentDate = endDate
            return dates
        }
        return []
    }
    
    func getExpenseTrail(strDates:[String]){
        if strDates.count > 1{
            self.lblWeekDate.text = "\(strDates.first ?? "") To \(strDates.last ?? "")"
            self.getChildWeekSummaryDetail(strDates: strDates)
        }
    }
    func configureFormDatePicker(){
        
        self.fromDatePickerToolbar.sizeToFit()
        self.fromDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.fromDatePickerToolbar.layer.borderWidth = 1.0
        self.fromDatePickerToolbar.clipsToBounds = true
        self.fromDatePickerToolbar.backgroundColor = UIColor.white
        self.fromDatePicker.datePickerMode = .date
        self.fromDatePicker.maximumDate = Date()
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(FilterDateHeaderView.doneFormDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"Date"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(FilterDateHeaderView.cancelFormDatePicker))
        
        self.fromDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        self.txtDateTextField.inputView = self.fromDatePicker
        self.txtDateTextField.inputAccessoryView = self.fromDatePickerToolbar
    }
    @objc func doneFormDatePicker(){
        DispatchQueue.main.async {
            self.txtDateTextField.resignFirstResponder()
        }
       print("\(self.fromDatePicker.date.yyyyMMdd)")
       //let objFilterArray = self.arrayOfWeeklyChildSummary.filter{$0.trip_date.changeDateFormateYYYY_MM_dd == "\(self.fromDatePicker.date.yyyyMMdd)" }
       //print(objFilterArray)
        self.pushToChildReportViewController(objChildSelectedDate: "\(self.fromDatePicker.date.yyyyMMdd)")
    }
    @objc func cancelFormDatePicker(){
        DispatchQueue.main.async {
            self.txtDateTextField.resignFirstResponder()
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonMissionMapSelector(sender:UIButton){
        self.presentMissionView()
    }
    @IBAction func buttonProfileSelector(sender:UIButton){
        self.pushToChildViewController()
    }
    @IBAction func buttonCalendarSelector(sender:UIButton){
            //self.pushToChildOBDConnectionViewController()
        DispatchQueue.main.async {
           self.txtDateTextField.becomeFirstResponder()
        }
    }
    func pushToChildOBDConnectionViewController(){
        
        if let objObdConnectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildConnectODBViewController") as? ChildConnectODBViewController{
            self.present(objObdConnectionViewController, animated: true, completion: nil)
        }
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
    
    @IBAction func buttonLeftSelector(sender:UIButton){
        DispatchQueue.main.async {
          
            if let startDate = Calendar.current.date(byAdding: .day, value: -7, to: self.currentDate){
                self.currentDate = startDate
            }
            let previousDates = self.getPreviousWeekDate(fromDate: self.currentDate)
            self.getExpenseTrail(strDates: previousDates)
        }
    }
    @IBAction func buttonRightSelector(sender:UIButton){
        print(self.currentDate)
        DispatchQueue.main.async {
            if let update = Calendar.current.date(byAdding: .day, value: 1, to: self.currentDate){
                self.currentDate = update
            }
            let nextDates = self.getNextWeekDate(fromDate: self.currentDate)
            self.getExpenseTrail(strDates: nextDates)
        }
    }
    // MARK: - API Request Methods
    func getChildWeekSummaryDetail(strDates:[String]){
        
        var parentSummaryParameters:[String:Any] = [:]
        parentSummaryParameters["start_date"] = "\(strDates.first?.changeDateFormateYYYY_MM_dd ?? "")"
        parentSummaryParameters["end_date"] = "\(strDates.last?.changeDateFormateYYYY_MM_dd ?? "")"
        
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kChildSummary, parameter:parentSummaryParameters as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    if let successData:[String:Any] =  objSuccess["data"] as? [String:Any]{
                        if let avgSummary = successData["avg_summary"] as? [String:Any]{
                            self.currentChildAVGSummary = AVGSummary.init(perfomance: "\(avgSummary["avg_performance"] ?? "")", grade: "\(avgSummary["grade"] ?? "")")
                        }
                        if let arrayOfSummary:[[String:Any]] = successData["summary"] as? [[String:Any]]{
                            self.arrayOfWeeklyChildSummary.removeAll()
                            for objSummary:[String:Any] in arrayOfSummary{
                                let objChildSummary = ChildSummary.init(avg_performance: "\(objSummary["avg_performance"] ?? "")", grade: "\(objSummary["grade"] ?? "")", harsh_break: "\(objSummary["harsh_break"] ?? "")", ideal_standby: "\(objSummary["ideal_standby"] ?? "")", over_speed: "\(objSummary["over_speed"] ?? "")", rapid_acceleration: "\(objSummary["rapid_acceleration"] ?? "")", top_speed: "\(objSummary["top_speed"] ?? "")", trip_date: "\(objSummary["trip_date"] ?? "")")
                                self.arrayOfWeeklyChildSummary.append(objChildSummary)
                            }
                            DispatchQueue.main.async {
                                self.collectionViewChild.reloadData()
                                self.tableViewSummary.reloadData()
                            }
                        }
                    }
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
    //Register Child UDID to server
    func registerChildDeviceUDIDAPIRequest(){
        if let identifierForVendor = UIDevice.current.identifierForVendor {
            var parametersForMDM:[String:Any] = [:]
            parametersForMDM["start_date"] = "\(identifierForVendor.uuidString)"
            parametersForMDM["device_type"] = "ios"
            
           
            
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kChildDevice, parameter:parametersForMDM as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in
                
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
        
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func presentMissionView(){
        if let objMIssionStatementViewController = self.storyboard?.instantiateViewController(withIdentifier: "MIssionStatementViewController") as? MIssionStatementViewController{
            objMIssionStatementViewController.modalPresentationStyle = .overCurrentContext
            self.tabBarController?.present(objMIssionStatementViewController, animated: false, completion: nil)
        }
    }
    func pushToChildViewController(){
        if let objChildProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildProfileViewController") as? ChildProfileViewController{
            objChildProfileViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objChildProfileViewController, animated: true)
        }
    }
    func pushToChildDiagnosis(){
        if let objChildProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildDiagnosticsViewController") as? ChildDiagnosticsViewController{
            objChildProfileViewController.hidesBottomBarWhenPushed = true
            objChildProfileViewController.isForChild = true
            self.navigationController?.pushViewController(objChildProfileViewController, animated: true)
        }
    }
    func pushToChildReportViewController(objChildSummary:ChildSummary){
        DispatchQueue.main.async {
            if let objChildReportViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildReportViewController") as? ChildReportViewController{
                objChildReportViewController.objChildSummary = objChildSummary
                objChildReportViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objChildReportViewController, animated: true)
            }
        }
    }
    func pushToChildReportViewController(objChildSelectedDate:String){
        
           DispatchQueue.main.async {
               if let objChildReportViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChildReportViewController") as? ChildReportViewController{
                   objChildReportViewController.currentSelectedDate = objChildSelectedDate
                   objChildReportViewController.hidesBottomBarWhenPushed = true
                   self.navigationController?.pushViewController(objChildReportViewController, animated: true)
               }
           }
       }
}
extension ChildSummaryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1//self.arrayOfSetting.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let objCell:ChildSummaryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildSummaryCollectionViewCell", for: indexPath) as! ChildSummaryCollectionViewCell
        DispatchQueue.main.async {
            if let objChild = self.currentChild{
               objCell.lblChildName.text = objChild.childName
                if let objURL = URL.init(string: objChild.childImage){
                    objCell.buttonChild?.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: nil)
                }
               objCell.buttonChild.imageView?.contentMode = .scaleAspectFill
            }
            if let _ = self.currentChildAVGSummary{
                objCell.buttonChildScore.setTitle(self.currentChildAVGSummary!.perfomance, for: .normal)
                
                let font:UIFont? = UIFont(name: "Poppins-Regular", size:34)
                let subfont:UIFont? = UIFont(name: "Poppins-Regular", size:20)
                
                let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(self.currentChildAVGSummary!.grade)", attributes: [.font:font!])
                attString.setAttributes([.font:subfont!,.baselineOffset:15], range: NSRange(location:1,length:1))
                objCell.lblChildScore.attributedText = attString
            }
            objCell.buttonViewDiagnosis.addTarget(self, action: #selector(self.buttonViewDiagnosisSelector(sender:)), for: .touchUpInside)
        }
        
        return objCell
    }
    @IBAction func buttonViewDiagnosisSelector(sender:UIButton){
        self.pushToChildDiagnosis()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        print(collectionView.bounds.height)
        return CGSize.init(width: collectionView.bounds.width-20, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10.0
    }
    /*
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     if indexPath.item == 0{//change password
     self.pushToParentChangePasswordViewController()
     }else if indexPath.item == 1{ //edit profile
     self.pushToEditProfileViewController()
     }else{//notification
     self.pushToParentNotificationSettingViewController()
     }
     }*/
}
extension ChildSummaryViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfWeeklyChildSummary.count//10//self.arrayOfNotificationSetting.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "ParentChildSummaryTableViewCell") as! ParentChildSummaryTableViewCell
        let objChildSummary = arrayOfWeeklyChildSummary[indexPath.row]
        
        objCell.lblDay.text = self.getDateFromString(strDate: objChildSummary.trip_date) ?? "SUN"
        objCell.lblDate.text = objChildSummary.trip_date.changeDateFormateddMMYYYY
        objCell.lblPercentage.text = objChildSummary.avg_performance
        objCell.lblOverSpeedCount.text = objChildSummary.over_speed
        objCell.lblHarshBreakCount.text = objChildSummary.harsh_break
        objCell.lblRapidCount.text = objChildSummary.rapid_acceleration
        objCell.lblIdealCount.text = objChildSummary.ideal_standby
        
        let font:UIFont? = UIFont(name: "Helvetica", size:20)
        let subfont:UIFont? = UIFont(name: "Helvetica", size:20)
        
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(objChildSummary.grade)", attributes: [.font:font!])
        attString.setAttributes([.font:subfont!,.baselineOffset:10], range: NSRange(location:1,length:1))
        objCell.lblGrade.attributedText = attString
        return objCell
    }
    func getDateFromString(strDate:String)->String?{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: strDate){
            let weekday:Int = Calendar.current.component(.weekday, from: date)
            return self.getWeekDayFromNumber(number: weekday)
        }
        return ""
    }
    func getWeekDayFromNumber(number:Int)->String{
        if  number == 1{ //the weekday number 1-7 (Sunday through Saturday)
            return "SUN"
        }else if number == 2{
            return "MON"
        }else if number == 3{
            return "TUE"
        }else if number == 4{
            return "WED"
        }else if number == 5{
            return "THURS"
        }else if number == 6{
            return "FRI"
        }else if number == 7{
            return "SAT"
        }else{
            return "SUN"
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160//UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objChildSummary = arrayOfWeeklyChildSummary[indexPath.row]
        self.pushToChildReportViewController(objChildSummary: objChildSummary)
    }
    
}
extension ChildSummaryViewController:CBCentralManagerDelegate{
    
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
        peripheral.delegate  = self
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
        DispatchQueue.main.async {
            ShowToast.show(toatMessage: "didConnect \(peripheral.name)")
        }
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
extension ChildSummaryViewController:CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("didWriteValueFor descriptor")
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueFor characteristic")
    }
    func didReadValueForCharacteristic(_ characteristic: CBCharacteristic) {
        print("didReadValueForCharacteristic")
                if let mac_address = characteristic.value?.hexEncodedString().uppercased(){
                let macAddress = mac_address.separate(every: 2, with: ":")
                print("MAC_ADDRESS: \(macAddress)")
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(macAddress)")
                    }
            }
    }
}
