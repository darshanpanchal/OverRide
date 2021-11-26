//
//  SummaryViewController.swift
//  TeenageSafety
//
//  Created by user on 04/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {

    @IBOutlet var lblWeekDate:UILabel!
    @IBOutlet var lblWeekDetail:UILabel!
    @IBOutlet var buttonLeft:UIButton!
    @IBOutlet var buttonRight:UIButton!
    
    @IBOutlet var collectionChild:UICollectionView!
    @IBOutlet var tableViewSummary:UITableView!
    
    var currentDate = Date()
    var dateFormate = DateFormatter()
    
    var arrayOfSetting:[String] = []
    
    var staticData:[SummaryStatic] = []
    
    @IBOutlet var containerView:UIView!
    
    @IBOutlet var txtDateTextField:UITextField!
    var fromDatePicker:UIDatePicker = UIDatePicker()
    var fromDatePickerToolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
    
    var arrayParentSummary:[ParenChildSummary] = []
    
    var arrayOfWeeklyChildSummary:[ChildSummary] = []
    
    var arrayOfWeekDate:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let appDel = UIApplication.shared.delegate as? AppDelegate{
            self.containerView.isHidden = appDel.isSprint1Only
            
        }
        //GET Selected Child Summary Data
        self.dateFormate.dateFormat = "dd MMM YYYY"
        self.getExpenseTrail(strDates: self.getCurrentWeekDate())
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func setup(){
       
        //configure collection view
        self.configureCollectionView()
        //configure table view
        self.cofigureTableView()
        
        self.configureStaticDate()
        
        //configure date picker
        self.configureFormDatePicker()
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

    func configureCollectionView(){
        
        let objNib = UINib.init(nibName: "ParentSummaryCollectionViewCell", bundle: nil)
        self.collectionChild.register(objNib, forCellWithReuseIdentifier: "ParentSummaryCollectionViewCell")
        self.collectionChild.delegate = self
        self.collectionChild.dataSource = self
        self.collectionChild.reloadData()
        self.collectionChild.allowsSelection = true
        self.collectionChild.layoutIfNeeded()
    }
    func cofigureTableView(){
        //ParentChildSummaryTableViewCell
        let objNib = UINib.init(nibName: "ParentChildSummaryTableViewCell", bundle: nil)
        self.tableViewSummary.register(objNib, forCellReuseIdentifier: "ParentChildSummaryTableViewCell")
        self.tableViewSummary.delegate = self
        self.tableViewSummary.dataSource = self
        self.tableViewSummary.reloadData()
        self.tableViewSummary.allowsSelection = true
        self.tableViewSummary.layoutIfNeeded()
    }
    // MARK: - Selectot Methods
    @IBAction func buttonLeftSelector(sender:UIButton){
        DispatchQueue.main.async {
            //            if let update = Calendar.current.date(byAdding: .day, value: -1, to: self.currentDate){
            //                self.currentDate = update
            //            }
            if let startDate = Calendar.current.date(byAdding: .day, value: -7, to: self.currentDate){
                self.currentDate = startDate
            }
            let previousDates = self.getPreviousWeekDate(fromDate: self.currentDate)
            self.getExpenseTrail(strDates: previousDates)
        }
    }
    @IBAction func buttonRightSelector(sender:UIButton){
        
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self.currentDate)
        let date2 = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        if let day = components.day{
            if day == 0{
                return
            }
        }
        print(self.currentDate)
        DispatchQueue.main.async {
            if let update = Calendar.current.date(byAdding: .day, value: 1, to: self.currentDate){
                self.currentDate = update
            }
            let nextDates = self.getNextWeekDate(fromDate: self.currentDate)
            self.getExpenseTrail(strDates: nextDates)
        }
    }
    @IBAction func buttonCalenderSelector(sender:UIButton){
        DispatchQueue.main.async {
           self.txtDateTextField.becomeFirstResponder()
        }
    }
    @IBAction func buttonProfileSelector(sender:UIButton){
        self.pushToParentProfileViewController()
    }
    func pushToParentProfileViewController(){
        if let objParentProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentProfileViewController") as? ParentProfileViewController{
            objParentProfileViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objParentProfileViewController, animated: true)
        }
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
            self.arrayOfWeekDate = strDates
            self.getParentSummaryDetail(strDates:strDates)
            if let app = UIApplication.shared.delegate as? AppDelegate{
                self.getParentChildWeekDetail(strDates: strDates, chidId: app.currentChildID ?? "0")
            }
            
        }
    }
    // MARK: - API request methods
    func getParentSummaryDetail(strDates:[String]){
        var parentSummaryParameters:[String:Any] = [:]
        parentSummaryParameters["start_date"] = "\(strDates.first?.changeDateFormateYYYY_MM_dd ?? "")"
        parentSummaryParameters["end_date"] = "\(strDates.last?.changeDateFormateYYYY_MM_dd ?? "")"
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentChildSummaryList, parameter:parentSummaryParameters as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    if let successData:[[String:Any]] =  objSuccess["data"] as? [[String:Any]]{
                        self.arrayParentSummary.removeAll()
                        for data in successData{
                            
                            if let avgSummary = data["avg_summary"] as? [String:Any]{
                                let avgSummary = AVGSummary.init(perfomance: "\(avgSummary["avg_performance"] ?? "")", grade: "\(avgSummary["grade"] ?? "")")
                                 let objData = ParenChildSummary.init(name: "\(data["name"] ?? "")", id: "\(data["id"] ?? "")", image: "\(data["image"] ?? "")", county_code: "\(data["country_code"] ?? "")", gender: "\(data["gender"] ?? "")", accss_token: "\(data["access_token"] ?? "")", phone: "\(data["phone"] ?? "")", email: "\(data["email"] ?? "")", dob: "\(data["dob"] ?? "")", avg_summary: avgSummary)
                                
                                self.arrayParentSummary.append(objData)
                            }
                        }
                        DispatchQueue.main.async {
                            self.collectionChild.reloadData()
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                                if let app = UIApplication.shared.delegate as? AppDelegate{
                                    if let currentChildID = app.currentChildID{
                                        if let index = self.arrayParentSummary.firstIndex(where: {$0.id == "\(currentChildID)"}){
                                            let objIndexPath = IndexPath.init(item: index, section: 0)
                                            self.collectionChild.scrollToItem(at: objIndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)

                                        }
                                    }
                                    
                                }
                            
                            })
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
    func getParentChildWeekDetail(strDates:[String],chidId:String){
        
        var parentSummaryParameters:[String:Any] = [:]
        parentSummaryParameters["start_date"] = "\(strDates.first?.changeDateFormateYYYY_MM_dd ?? "")"
        parentSummaryParameters["end_date"] = "\(strDates.last?.changeDateFormateYYYY_MM_dd ?? "")"
        parentSummaryParameters["id"] = "\(chidId)"
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentChildWeekSummary, parameter:parentSummaryParameters as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    if let successData:[String:Any] =  objSuccess["data"] as? [String:Any]{
                        if let arrayOfSummary:[[String:Any]] = successData["summary"] as? [[String:Any]]{
                            self.arrayOfWeeklyChildSummary.removeAll()
                            for objSummary:[String:Any] in arrayOfSummary{
                                    let objChildSummary = ChildSummary.init(avg_performance: "\(objSummary["avg_performance"] ?? "")", grade: "\(objSummary["grade"] ?? "")", harsh_break: "\(objSummary["harsh_break"] ?? "")", ideal_standby: "\(objSummary["ideal_standby"] ?? "")", over_speed: "\(objSummary["over_speed"] ?? "")", rapid_acceleration: "\(objSummary["rapid_acceleration"] ?? "")", top_speed: "\(objSummary["top_speed"] ?? "")", trip_date: "\(objSummary["trip_date"] ?? "")")
                                self.arrayOfWeeklyChildSummary.append(objChildSummary)
                            }
                            DispatchQueue.main.async {
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
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }*/
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToChildReportViewController(objChildSummary:ChildSummary){
        DispatchQueue.main.async {
            if let objChildReportViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentChildReportViewController") as? ParentChildReportViewController{
                objChildReportViewController.objChildSummary = objChildSummary
                objChildReportViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objChildReportViewController, animated: true)
            }
        }
    }
    func pushToChildReportViewController(objChildSelectedDate:String){
        DispatchQueue.main.async {
            if let objChildReportViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentChildReportViewController") as? ParentChildReportViewController{
                objChildReportViewController.currentSelectedDate = objChildSelectedDate
                objChildReportViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objChildReportViewController, animated: true)
            }
        }
    }
    func pushToChildDiagnosisViewController(childID:String){
        DispatchQueue.main.async {
            if let objChildVehicleDiagnosis = self.storyboard?.instantiateViewController(withIdentifier: "ChildDiagnosticsViewController") as? ChildDiagnosticsViewController{
                objChildVehicleDiagnosis.objChildID = childID
                objChildVehicleDiagnosis.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objChildVehicleDiagnosis, animated: true)
            }
        }
    }
}
extension SummaryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayParentSummary.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let objCell:ParentSummaryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParentSummaryCollectionViewCell", for: indexPath) as! ParentSummaryCollectionViewCell
        let objChildSummary = self.arrayParentSummary[indexPath.item]
        
        objCell.lblChildName.text = objChildSummary.name
        objCell.buttonChildScore.setTitle(objChildSummary.avg_summary.perfomance, for: .normal)
        
        let font:UIFont? = UIFont(name: "Poppins-Regular", size:20)
        let subfont:UIFont? = UIFont(name: "Poppins-Regular", size:20)
        
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(objChildSummary.avg_summary.grade)", attributes: [.font:font!])
        attString.setAttributes([.font:subfont!,.baselineOffset:10], range: NSRange(location:1,length:1))
        objCell.lblChildScore.attributedText = attString
        let objURL = URL.init(string: objChildSummary.image)
        objCell.buttonChildImage.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: nil)
        objCell.buttonChildImage.imageView?.contentMode = .scaleAspectFill
        objCell.buttonVehicleDiagnostics.tag = indexPath.item
        objCell.buttonVehicleDiagnostics.addTarget(self, action: #selector(buttonVehicleDiagnosticsSelector(sender:)), for: .touchUpInside)
        
        if self.getIndexOfCurrentChild(child: objChildSummary){
            objCell.configureCurrentChild(isSelected: true)
        }else{
            objCell.configureCurrentChild(isSelected: false)
        }
        return objCell
    }
    @IBAction func buttonVehicleDiagnosticsSelector(sender:UIButton){
        if self.arrayParentSummary.count > sender.tag{
            let objChildSummary = self.arrayParentSummary[sender.tag]
            self.pushToChildDiagnosisViewController(childID: objChildSummary.id)
        }
        
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
        return CGSize.init(width: collectionView.bounds.width/1.5, height: collectionView.bounds.height-10.0)//CGSize.init(width: UIScreen.main.bounds.height, height:  UIScreen.main.bounds.height)//collectionView.bounds.size.width*0.5+50+30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10.0
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let app = UIApplication.shared.delegate as? AppDelegate{
            let objChild = self.arrayParentSummary[indexPath.item]
            app.currentChildID = objChild.id
            self.saveSelectedChild(id: app.currentChildID ?? "0")
            self.collectionChild.performBatchUpdates({
                let indexSet = IndexSet(integer: 0)
                self.collectionChild.reloadSections(indexSet)
            }, completion: nil)
            self.getParentChildWeekDetail(strDates: self.arrayOfWeekDate, chidId: objChild.id)
        }
    }
    func saveSelectedChild(id:String){
        UserDefaults.standard.set(id, forKey: "currentChild")
        UserDefaults.standard.synchronize()
    }
}
extension SummaryViewController:UITableViewDelegate,UITableViewDataSource{
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
        return 160.0//UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objChildSummary = arrayOfWeeklyChildSummary[indexPath.row]
        self.pushToChildReportViewController(objChildSummary: objChildSummary)
    }
    
}
struct SummaryStatic {
    var day, date, percentage, overspeed, harshbreak, rapid, ideal:String
}
struct ParenChildSummary {
    var name, id, image, county_code, gender, accss_token, phone, email, dob :String
    var avg_summary:AVGSummary
    
}
struct AVGSummary {
    var perfomance, grade:String
}
struct ParentChildWeeklySummary {
    var name, id, image, county_code, gender, accss_token, phone, email, dob :String
    var summary:[ChildSummary]
}
struct ChildSummary {
    var avg_performance, grade, harsh_break, ideal_standby, over_speed, rapid_acceleration, top_speed, trip_date:String
}
