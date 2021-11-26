//
//  ParentChildReportViewController.swift
//  TeenageSafety
//
//  Created by user on 24/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ParentChildReportViewController: UIViewController {

    
    @IBOutlet var lblDay:UILabel!
    @IBOutlet var lblDate:UILabel!
    @IBOutlet var lblGrade:UILabel!
    
    
    @IBOutlet var collectionChild:UICollectionView!
    @IBOutlet var tableViewChildReport:UITableView!
    
    @IBOutlet var childReportContainerView:UIView!
    
    @IBOutlet var buttonPerformance:UIButton!
    @IBOutlet var lblPerformanceType:UILabel!
    
    @IBOutlet var lblOverSpeedCount:UILabel!
    @IBOutlet var lblHarshBreakCount:UILabel!
    @IBOutlet var lblRapidAccelarationCount:UILabel!
    @IBOutlet var lblIdealStandByCount:UILabel!
    
    @IBOutlet var txtDateTextField:UITextField!
    
    
    
    var objChildSummary:ChildSummary?
    
    var arrayParentChildReport:[ParenChildSummary] = []

    
    var arrayOfTrips:[ChildTrip] = []
    
    var objCurrentChildReportSummary:ChildReportSummary?
    
    var currentSelectedDate:String?
    
    var fromDatePicker:UIDatePicker = UIDatePicker()
    var fromDatePickerToolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup methods
        self.setup()
    }
    

    // MARK: - Custom Methods
    func setup(){
        self.childReportContainerView.clipsToBounds = true
        self.childReportContainerView.layer.cornerRadius = 10.0
        
        self.buttonPerformance.layer.cornerRadius = 12.0
        self.buttonPerformance.layer.borderWidth = 2.0
        self.buttonPerformance.layer.borderColor = UIColor.init(hexString: "#707070").cgColor
        
        self.configureCollectionView()
        
        self.configureTableView()
        
        if let _ = self.objChildSummary{
            self.lblDate.text = self.objChildSummary!.trip_date.changeDateFormateddMMYYYY
            self.lblDay.text = self.getDateFromString(strDate: self.objChildSummary!.trip_date)
            self.getChildListReportAPIRequest(objDate: "\(self.objChildSummary!.trip_date.changeDateFormateYYYY_MM_dd)")
            if let app = UIApplication.shared.delegate as? AppDelegate{
                self.getParentChildTripReportAPIRequest(childID: app.currentChildID ?? "0", strDate:  "\(self.objChildSummary!.trip_date.changeDateFormateYYYY_MM_dd)")
            }
        }else if let currentDate = self.currentSelectedDate{
            self.lblDate.text = currentDate.changeDateFormateddMMYYYY
            self.lblDay.text = self.getDateFromString(strDate: currentDate)
            self.getChildListReportAPIRequest(objDate: "\(currentDate)")
            if let app = UIApplication.shared.delegate as? AppDelegate{
                self.getParentChildTripReportAPIRequest(childID: app.currentChildID ?? "0", strDate:  "\(currentDate)")
            }
        }
        self.configureFormDatePicker()
    }
    
    func configureCollectionView(){
        let objNib = UINib.init(nibName: "ParentSummaryCollectionViewCell", bundle: nil)
        self.collectionChild.register(objNib, forCellWithReuseIdentifier: "ParentSummaryCollectionViewCell")
        self.collectionChild.delegate = self
        self.collectionChild.dataSource = self
        self.collectionChild.reloadData()
        self.collectionChild.allowsSelection = true
        self.collectionChild.layoutIfNeeded()
    }
    func configureTableView(){
        
        let objNib = UINib.init(nibName: "ParentChildReportTableViewCell", bundle: nil)
        self.tableViewChildReport.register(objNib, forCellReuseIdentifier: "ParentChildReportTableViewCell")
        self.tableViewChildReport.delegate = self
        self.tableViewChildReport.dataSource = self
        self.tableViewChildReport.reloadData()
        self.tableViewChildReport.allowsSelection = true
        self.tableViewChildReport.layoutIfNeeded()
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
            return "Sunday"
        }else if number == 2{
            return "Monday"
        }else if number == 3{
            return "Tuesday"
        }else if number == 4{
            return "Wednesday"
        }else if number == 5{
            return "Thursday"
        }else if number == 6{
            return "Friday"
        }else if number == 7{
            return "Satureday"
        }else{
            return "Sunday"
        }
        
    }
    //configure Date picker
    func configureFormDatePicker(){
           
           self.fromDatePickerToolbar.sizeToFit()
           self.fromDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
           self.fromDatePickerToolbar.layer.borderWidth = 1.0
           self.fromDatePickerToolbar.clipsToBounds = true
           self.fromDatePickerToolbar.backgroundColor = UIColor.white
           self.fromDatePicker.datePickerMode = .date
           self.fromDatePicker.maximumDate = Date()
           //        self.fromDatePicker.set18YearValidation()
           
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
          print("\(self.currentSelectedDate)")
          self.currentSelectedDate = "\(self.fromDatePicker.date.yyyyMMdd)"
            if let currentDate = self.currentSelectedDate{
                self.lblDate.text = currentDate.changeDateFormateddMMYYYY
                self.lblDay.text = self.getDateFromString(strDate: currentDate)
                self.getChildListReportAPIRequest(objDate: "\(currentDate)")
            }
       }
       @objc func cancelFormDatePicker(){
           DispatchQueue.main.async {
               self.txtDateTextField.resignFirstResponder()
           }
       }

    // MARK: - API Request Methods Methods
    func getChildListReportAPIRequest(objDate:String){
        var parentChildReportParameters:[String:Any] = [:]
        if let _ = self.objChildSummary{
            parentChildReportParameters["date"] = objDate
        }else if let _ = self.currentSelectedDate{
            parentChildReportParameters["date"] = objDate
        }
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentChildReportList, parameter:parentChildReportParameters as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    if let successData:[[String:Any]] =  objSuccess["data"] as? [[String:Any]]{
                        self.arrayParentChildReport.removeAll()
                        for data in successData{
                            
                            if let avgSummary = data["avg_report"] as? [String:Any]{
                                let avgSummary = AVGSummary.init(perfomance: "\(avgSummary["avg_performance"] ?? "")", grade: "\(avgSummary["grade"] ?? "")")
                                let objData = ParenChildSummary.init(name: "\(data["name"] ?? "")", id: "\(data["id"] ?? "")", image: "\(data["image"] ?? "")", county_code: "\(data["country_code"] ?? "")", gender: "\(data["gender"] ?? "")", accss_token: "\(data["access_token"] ?? "")", phone: "\(data["phone"] ?? "")", email: "\(data["email"] ?? "")", dob: "\(data["dob"] ?? "")", avg_summary: avgSummary)
                                self.arrayParentChildReport.append(objData)
                            }
                        }
                        DispatchQueue.main.async {
                            self.collectionChild.reloadData()
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
    //kParentChildReport
    func getParentChildTripReportAPIRequest(childID:String,strDate:String){
        var childReportParameters:[String:Any] = [:]
        childReportParameters["start_date"] = "\(strDate)"
        childReportParameters["id"] = "\(childID)"
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentChildReport, parameter:childReportParameters as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    if let successData:[String:Any] =  objSuccess["data"] as? [String:Any],let reportData:[String:Any] = successData["report"] as? [String:Any] {
                        if let arrayTrip:[[String:Any]] = reportData["trips"] as? [[String:Any]]{
                            self.arrayOfTrips.removeAll()
                            for objTrip in arrayTrip{
                                var arrayTripRoute:[TripRoute] = []

                                if let arrayRoute:[[String:Any]] = objTrip["route"] as? [[String:Any]]{
                                    for objRoute in arrayRoute{
                                        let objTripRoute = TripRoute.init(latitude: "\(objRoute["latitude"] ?? "")", longitude: "\(objRoute["longitude"] ?? "")")
                                        arrayTripRoute.append(objTripRoute)
                                    }
                                }
                                let objChildTrip = ChildTrip.init(distance: "\(objTrip["distance"] ?? "")", duration: "\(objTrip["duration"] ?? "")", from: "\(objTrip["from"] ?? "")", from_time: "\(objTrip["from_time"] ?? "")", grade: "\(objTrip["grade"] ?? "")", harsh_break: "\(objTrip["harsh_break"] ?? "")", ideal_standby: "\(objTrip["ideal_standby"] ?? "")", over_speed: "\(objTrip["over_speed"] ?? "")", performance_type: "\(objTrip["performance_type"] ?? "")", rapid_acceleration: "\(objTrip["rapid_acceleration"] ?? "")", to: "\(objTrip["to"] ?? "")", to_time: "\(objTrip["to_time"] ?? "")", top_speed: "\(objTrip["top_speed"] ?? "")", trip_performance: "\(objTrip["trip_performance"] ?? "")", route: arrayTripRoute)
                                
                                self.arrayOfTrips.append(objChildTrip)
                            }
                            
                            self.objCurrentChildReportSummary = ChildReportSummary.init(avg_performance: "\(reportData["avg_performance"] ?? "")", grade: "\(reportData["grade"] ?? "")", harsh_break: "\(reportData["harsh_break"] ?? "")", ideal_standby: "\(reportData["ideal_standby"] ?? "")", over_speed: "\(reportData["over_speed"] ?? "")", performance_type: "\(reportData["performance_type"] ?? "")", rapid_acceleration: "\(reportData["rapid_acceleration"] ?? "")", report_date: "\(reportData["report_date"] ?? "")", top_speed: "\(reportData["top_speed"] ?? "")", trips: self.arrayOfTrips)
                            
                            if let _ = self.objCurrentChildReportSummary{
                                self.configureCurrentChildReportSummary()
                            }
                        }
                     
                        DispatchQueue.main.async {
                            self.tableViewChildReport.reloadData()
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
    func configureCurrentChildReportSummary(){
        if let _ = self.objCurrentChildReportSummary{
            //self.lblGrade.text = self.objCurrentChildReportSummary!.grade
            let font:UIFont? = UIFont(name: "Poppins-Regular", size:41)
            let subfont:UIFont? = UIFont(name: "Poppins-Regular", size:30)
            
            let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(self.objCurrentChildReportSummary!.grade)", attributes: [.font:font!])
            attString.setAttributes([.font:subfont!,.baselineOffset:20], range: NSRange(location:1,length:1))
            self.lblGrade.attributedText = attString
            self.buttonPerformance.setTitle("\(self.objCurrentChildReportSummary!.avg_performance)", for: .normal)
            self.lblOverSpeedCount.text = "\(self.objCurrentChildReportSummary!.over_speed)"
            self.lblHarshBreakCount.text = "\(self.objCurrentChildReportSummary!.harsh_break)"
            self.lblIdealStandByCount.text = "\(self.objCurrentChildReportSummary!.ideal_standby)"
            self.lblRapidAccelarationCount.text = "\(self.objCurrentChildReportSummary!.rapid_acceleration)"
            
            DispatchQueue.main.async {
                self.tableViewChildReport.reloadData()
            }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonCalenderSelector(sender:UIButton){
        DispatchQueue.main.async {
           self.txtDateTextField.becomeFirstResponder()
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToTripDetailViewController(objTrip:ChildTrip){
        if let objTripDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "TripDetailViewController") as? TripDetailViewController{
            objTripDetailViewController.objChildTrip = objTrip
            self.navigationController?.pushViewController(objTripDetailViewController, animated: true)
        }
    }
    

}
extension ParentChildReportViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayParentChildReport.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let objCell:ParentSummaryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParentSummaryCollectionViewCell", for: indexPath) as! ParentSummaryCollectionViewCell
        
        let objChildReport = arrayParentChildReport[indexPath.item]
        
        objCell.lblChildName.text = objChildReport.name
        objCell.buttonChildScore.setTitle(objChildReport.avg_summary.perfomance, for: .normal)
        
        let font:UIFont? = UIFont(name: "Poppins-Regular", size:30)
        let subfont:UIFont? = UIFont(name: "Poppins-Regular", size:25)
        
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(objChildReport.avg_summary.grade)", attributes: [.font:font!])
        attString.setAttributes([.font:subfont!,.baselineOffset:15], range: NSRange(location:1,length:1))
        objCell.lblChildScore.attributedText = attString
        let objURL = URL.init(string: objChildReport.image)
        objCell.buttonChildImage.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: nil)
        objCell.buttonChildImage.imageView?.contentMode = .scaleAspectFill
        
        objCell.buttonVehicleDiagnostics.isHidden = true
        if self.getIndexOfCurrentChild(child: objChildReport){
            objCell.configureCurrentChild(isSelected: true)
        }else{
            objCell.configureCurrentChild(isSelected: false)
        }
        return objCell
    }
    func getIndexOfCurrentChild(child:ParenChildSummary)->Bool{
        if let app = UIApplication.shared.delegate as? AppDelegate{
            if let objID = app.currentChildID,objID == child.id{
                return true
            }else{
                return false
            }
        }
        return false
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: collectionView.bounds.width/1.5, height: collectionView.bounds.height)//CGSize.init(width: UIScreen.main.bounds.height, height:  UIScreen.main.bounds.height)//collectionView.bounds.size.width*0.5+50+30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let app = UIApplication.shared.delegate as? AppDelegate{
            let objChild = self.arrayParentChildReport[indexPath.item]
            app.currentChildID = objChild.id
            self.saveSelectedChild(id: app.currentChildID ?? "0")
            self.collectionChild.performBatchUpdates({
                let indexSet = IndexSet(integer: 0)
                self.collectionChild.reloadSections(indexSet)
            }, completion: nil)
            if let _ = self.objChildSummary{
                if let app = UIApplication.shared.delegate as? AppDelegate{
                    self.getParentChildTripReportAPIRequest(childID: app.currentChildID ?? "0", strDate:  "\(self.objChildSummary!.trip_date.changeDateFormateYYYY_MM_dd)")
                }
            }else if let currentDate = self.currentSelectedDate{
                if let app = UIApplication.shared.delegate as? AppDelegate{
                    self.getParentChildTripReportAPIRequest(childID: app.currentChildID ?? "0", strDate:  "\(currentDate)")
                }
            }
            
        }
    }
    func saveSelectedChild(id:String){
        UserDefaults.standard.set(id, forKey: "currentChild")
        UserDefaults.standard.synchronize()
    }
}
extension ParentChildReportViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = self.objCurrentChildReportSummary{
            return self.objCurrentChildReportSummary!.trips.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "ParentChildReportTableViewCell") as! ParentChildReportTableViewCell
        if let _ = self.objCurrentChildReportSummary{
            let objTrip = self.objCurrentChildReportSummary!.trips[indexPath.row]
            objCell.lblTripCount.text = "Trip \(indexPath.row + 1)"
            objCell.lblTopSpeed.text = objTrip.top_speed
            
            let font:UIFont? = UIFont(name: "Poppins-Regular", size:20)
            let subfont:UIFont? = UIFont(name: "Poppins-Regular", size:15)
            let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(objTrip.grade)", attributes: [.font:font!])
            attString.setAttributes([.font:subfont!,.baselineOffset:10], range: NSRange(location:1,length:1))
            objCell.lblDriveGrade.attributedText = attString
            
            objCell.lblPercentage.text = objTrip.trip_performance
            objCell.lblPerformanceType.text = objTrip.performance_type
            
            objCell.lblFromLocation.text = objTrip.from
            objCell.lblFromTime.text = objTrip.from_time
            objCell.lblToLocation.text = objTrip.to
            objCell.lblToTime.text = objTrip.to_time
            
            return objCell
        }
        return UITableViewCell()
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190.0//UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let objChildSummary = arrayOfWeeklyChildSummary[indexPath.row]
//        self.pushToChildReportViewController(objChildSummary: objChildSummary)
        if let _ = self.objCurrentChildReportSummary{
            let objTrip = self.objCurrentChildReportSummary!.trips[indexPath.row]
             self.pushToTripDetailViewController(objTrip: objTrip)
        }
        
    }
    
}
struct ChildReportSummary {
    var avg_performance, grade, harsh_break, ideal_standby, over_speed, performance_type,rapid_acceleration, report_date, top_speed:String
    var trips:[ChildTrip]
}
struct ChildTrip {
    var distance, duration, from, from_time, grade, harsh_break, ideal_standby, over_speed, performance_type,rapid_acceleration, to, to_time, top_speed, trip_performance:String
    var route:[TripRoute]
}
struct TripRoute {
    var latitude, longitude:String
}
