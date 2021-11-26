//
//  NotificationFilterViewController.swift
//  TeenageSafety
//
//  Created by user on 11/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
protocol FilterDelegate {
    func applyFilterOnSelectedChildDateCategory(filterParameters:[String:Any])
}
class NotificationFilterViewController: UIViewController {

    @IBOutlet var tableViewFilter:UITableView!
    
    @IBOutlet var buttonBackSelector:UIButton!
    
    
    var selectionSet:NSMutableSet = NSMutableSet(){
        didSet{
            self.configureUpdateSet()
        }
       
    }
    var arrayOfChild:[ChildModel] = []
    var araryOfCategory:[String] = []
    var notificationFilter:[String:Any] = [:]
    var currentFilterDate:String = ""
    
    var filterDelegate:FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectionSet.removeAllObjects()
        // Do any additional setup after loading the view.
        self.configureTableView()
//        self.notificationFilter["id"] = [18,19,21]
//        self.notificationFilter["date"] = "2019-12-11"
//        self.notificationFilter["category"] = "sos,app_request"
        //request for parent notification filter
        self.getParentFilterAPIRequest()
       
      
    }
    func configureTableView(){
        let objNib = UINib.init(nibName: "FilterDateHeaderView", bundle: nil)
        self.tableViewFilter.register(objNib, forHeaderFooterViewReuseIdentifier: "FilterDateHeaderView")
        self.tableViewFilter.allowsSelection = true
        self.tableViewFilter.delegate = self
        self.tableViewFilter.dataSource = self
        self.tableViewFilter.reloadData()
        self.tableViewFilter.tableFooterView = UIView()
    }
    func configureCurrentFilterParameters(){
        //configure filter date
        if let filterDate = self.notificationFilter["date"]{
            self.currentFilterDate = "\(filterDate)".changeDateFormateddMMYYYY
        }
        //configure selected child
        if let arraychildID = self.notificationFilter["id"] as? [Int]{
            for objID in arraychildID{
                if let index = self.arrayOfChild.firstIndex(where: {$0.id == "\(objID)"}){
                    let objIndexPath = IndexPath.init(item: index+1, section: 1)
                    self.selectionSet.add(objIndexPath)
                }
            }
            if self.arrayOfChild.count == arraychildID.count{
                let objIndexPath = IndexPath.init(item: 0, section: 1)
                self.selectionSet.add(objIndexPath)
            }
        }
        //configure selected category
        if let selectedCategory = self.notificationFilter["category"] as? String{
           let arrayCategory = selectedCategory.components(separatedBy: ",")
                for objCategory in arrayCategory{
                    if let index = self.araryOfCategory.firstIndex(where: {$0 == "\(objCategory)"}){
                        let objIndexPath = IndexPath.init(item: index+1, section: 2)
                        self.selectionSet.add(objIndexPath)
                    }
                }
            if self.araryOfCategory.count == arrayCategory.count{
                let objIndexPath = IndexPath.init(item: 0, section: 2)
                self.selectionSet.add(objIndexPath)
            }
        }
        DispatchQueue.main.async {
            self.tableViewFilter.reloadData()
        }
    }
    
    func configureUpdateSet(){
        if let allIndexPath = self.selectionSet.allObjects as? [IndexPath]{
            //filter child
            let arrayChildIndex = allIndexPath.filter{$0.section == 1 && $0.row != 0}
            let arrayChildItem = arrayChildIndex.compactMap{$0.item}
            var selectedChildID:[Int] = []
            for index in arrayChildItem{
                if index != 0{
                    let objChild = self.arrayOfChild[index-1]
                    selectedChildID.append(Int(objChild.id) ?? 0)
                }
            }
            self.notificationFilter["id"] = selectedChildID
            
            //filter Category
            let arrayCategoryIndex = allIndexPath.filter{$0.section == 2 && $0.row != 0}
            let arrayCategoryItem = arrayCategoryIndex.compactMap{$0.item}
            var selectedCategory:[String] = []
            for index in arrayCategoryItem{
                if index != 0{
                     let objCategory = self.araryOfCategory[index-1]
                     selectedCategory.append(objCategory)
                }
            }
            self.notificationFilter["category"] = selectedCategory.joined(separator:",")

            print(notificationFilter)
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonApplyFilterSelector(sender:UIButton){
        if let _ = self.filterDelegate{
            self.filterDelegate!.applyFilterOnSelectedChildDateCategory(filterParameters: self.notificationFilter)
             self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - API Request Methods
    func getParentFilterAPIRequest(){
        //parent/notificationfilter
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: kParentGETNotificationFilter, parameter:nil, isHudeShow: true, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                
                if let successData = objSuccess["data"] as? [String:Any]{
                    self.araryOfCategory.removeAll()
                    if let arraycategory = successData["category"] as? [String]{
                            print(arraycategory)
                        self.araryOfCategory = arraycategory
                    }
                    if let arrayOfChild = successData["child"] as? [[String:Any]]{
                        self.arrayOfChild.removeAll()
                        for var childJSON:[String:Any] in arrayOfChild{
                            childJSON.updateJSONNullToString()
                            childJSON.updateJSONToString()
                            do {
                                let jsondata = try JSONSerialization.data(withJSONObject:childJSON, options:.prettyPrinted)
                                
                                if let achievementData = try? JSONDecoder().decode(ChildModel.self, from: jsondata){
                                    self.arrayOfChild.append(achievementData)
                                }
                                
                            }catch{
                                
                            }
                        }
                       //update ui
                        print(self.araryOfCategory)
                        print(self.arrayOfChild)
                        DispatchQueue.main.async(execute: {
                            self.tableViewFilter.reloadData()
                            //Configure Current Filter Parameters
                            self.configureCurrentFilterParameters()
                        })
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
                }
            }
        }
    }
    func updateChildRequestAccessPermission(){
        var updateChildParameters:[String:Any] = [:]
       
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kParentChildAppAccess, parameter:updateChildParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let message:String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    if let keyWindow = UIApplication.shared.keyWindow{
                        keyWindow.showToast(message: message, isBlack: true)
                    }
                    self.navigationController?.popViewController(animated: true)
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
extension NotificationFilterViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
          return 0
        }else if section == 1{
          return self.arrayOfChild.count + 1
        }else if section == 2{
          return self.araryOfCategory.count + 1
        }else{
          return 2
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell") as! FilterTableViewCell
        objCell.buttonSelect.tag = indexPath.row
        objCell.buttonSelect.accessibilityValue = "\(indexPath.section)"
        objCell.buttonSelect.addTarget(self, action: #selector(buttonSelectRequestSelector(sender:)), for: .touchUpInside)
        if indexPath.row == 0{
             objCell.lblName.text = "All"
        }else{
            if indexPath.section == 1{
                let objChild = self.arrayOfChild[indexPath.row - 1]
                objCell.lblName.text = objChild.name
            }else if indexPath.section == 2{
                let objCategory = self.araryOfCategory[indexPath.row - 1]
                objCell.lblName.text = objCategory
            }else{
                
            }
        }
        if self.selectionSet.contains(indexPath){
            objCell.buttonSelect.setBackgroundImage(UIImage.init(named: "filer_select"), for: .normal)
        }else{
            objCell.buttonSelect.setBackgroundImage(UIImage.init(named: "filer_deselect"), for: .normal)
        }
        return objCell
    }
    @IBAction func buttonSelectRequestSelector(sender:UIButton){
        
        if let section = sender.accessibilityValue,let sectionValue = Int(section){
            let indexPath = IndexPath.init(row: sender.tag, section: sectionValue)
            if self.selectionSet.contains(indexPath){
                self.selectionSet.remove(indexPath)
                //remove all selector if added
                if indexPath.section == 1{
                    let firstIndexPath = IndexPath.init(item: 0, section: 1)
                    if self.selectionSet.contains(firstIndexPath){
                        self.selectionSet.remove(firstIndexPath)
                    }
                }else if indexPath.section == 2{
                    let firstIndexPath = IndexPath.init(item: 0, section: 2)
                    if self.selectionSet.contains(firstIndexPath){
                        self.selectionSet.remove(firstIndexPath)
                    }
                }
                //configureAllDeselect
                self.configureAllDeSelector(indexPath: indexPath)
            }else{
                self.selectionSet.add(indexPath)
                //add all selector if all selected
                self.addAllSelectorIfAllOtherSelected(indexPath: indexPath)
                //configureAllSelect
                self.configureSelectAllSelector(indexPath: indexPath)
            }
            
            DispatchQueue.main.async {
                self.configureUpdateSet()
                self.tableViewFilter.reloadData()
            }
            print("Row \(sender.tag)")
            print("Section \(section)")
            print("Number Of Row \(self.tableViewFilter.numberOfRows(inSection: Int(section) ?? 0 ))")
            
        }
        
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let objHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterDateHeaderView") as! FilterDateHeaderView
            objHeader.configureFormDatePicker()
            objHeader.filerDateDelegate = self
            if self.currentFilterDate.count > 0{
                objHeader.txtDate.text = self.currentFilterDate
            }
            return objHeader
        }else{
            let objView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
            let objLable = UILabel.init(frame: CGRect.init(x: 10, y: 10, width: tableView.bounds.width, height: 20.0))
            objLable.textColor = UIColor.black
            if section == 1{
                objLable.text = "Child"
            }else if section == 2{
                objLable.text = "Category"
            }else{
                objLable.text = ""
            }
            
            objLable.font = UIFont(name: "Poppins-SemiBold", size: 14.0)!
            objView.addSubview(objLable)
            objView.backgroundColor = UIColor.white
            return objView
        }
       
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 90.0
        }else{
            return 40.0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0//UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            if self.selectionSet.contains(indexPath){
                self.selectionSet.remove(indexPath)
                
                if indexPath.section == 1{
                    //remove all selector if added
                    let firstIndexPath = IndexPath.init(item: 0, section: 1)
                    if self.selectionSet.contains(firstIndexPath){
                        self.selectionSet.remove(firstIndexPath)
                    }
                }else if indexPath.section == 2{
                    //remove all selector if added
                    let firstIndexPath = IndexPath.init(item: 0, section: 2)
                    if self.selectionSet.contains(firstIndexPath){
                        self.selectionSet.remove(firstIndexPath)
                    }
                }
                //configureAllDeSelect
                self.configureAllDeSelector(indexPath: indexPath)
            }else{
                self.selectionSet.add(indexPath)
                
                //Select All
                self.addAllSelectorIfAllOtherSelected(indexPath: indexPath)
                
                //configureAllSelect
                self.configureSelectAllSelector(indexPath: indexPath)
               
            }
        DispatchQueue.main.async {
            self.configureUpdateSet()
            self.tableViewFilter.reloadData()
        }
    }
    func addAllSelectorIfAllOtherSelected(indexPath:IndexPath){
        if indexPath.section == 1,indexPath.row != 0{
            var isContainAll = 0
            for index in 1..<self.arrayOfChild.count+1{
                let objIndexPath = IndexPath.init(item: index, section: 1)
                if self.selectionSet.contains(objIndexPath){
                    isContainAll += 1
                }
            }
            if isContainAll == self.arrayOfChild.count{
                // add first index if contain All
                let firstIndexPath = IndexPath.init(item: 0, section: 1)
                self.selectionSet.add(firstIndexPath)
            }
        }else if indexPath.section == 2,indexPath.row != 0{
            var isContainAll = 0
            for index in 1..<self.araryOfCategory.count+1{
                let objIndexPath = IndexPath.init(item: index, section: 2)
                if self.selectionSet.contains(objIndexPath){
                    isContainAll += 1
                }
            }
            if isContainAll == self.araryOfCategory.count{
                // add first index if contain All
                let firstIndexPath = IndexPath.init(item: 0, section: 2)
                self.selectionSet.add(firstIndexPath)
            }
        }
    }
    func configureSelectAllSelector(indexPath:IndexPath){
        if indexPath.section == 1,indexPath.row == 0{ //child
            
            for index in 0..<self.arrayOfChild.count+1{
                print(index)
                let objIndexPath = IndexPath.init(item: index, section: 1)
                self.selectionSet.add(objIndexPath)
                
            }
        }else if indexPath.section == 2,indexPath.row == 0{//category
            for index in 0..<self.araryOfCategory.count+1{
                print(index)
                let objIndexPath = IndexPath.init(item: index, section: 2)
                self.selectionSet.add(objIndexPath)
            }
        }
    }
    func configureAllDeSelector(indexPath:IndexPath){
        if indexPath.section == 1,indexPath.row == 0{ //child
            
            for index in 0..<self.arrayOfChild.count+1{
                print(index)
                let objIndexPath = IndexPath.init(item: index, section: 1)
                if self.selectionSet.contains(objIndexPath){
                    self.selectionSet.remove(objIndexPath)
                }
            }
        }else if indexPath.section == 2,indexPath.row == 0{//category
            for index in 0..<self.araryOfCategory.count+1{
                print(index)
                let objIndexPath = IndexPath.init(item: index, section: 2)
                if self.selectionSet.contains(objIndexPath){
                    self.selectionSet.remove(objIndexPath)
                }
            }
        }
    }
    
}
extension NotificationFilterViewController:FilterHeaderViewDelegate{
    
    func updateFilterParameters(filterParameters: [String : Any]) {
        if let selectedDate = filterParameters["dob"]{
            self.currentFilterDate = "\(selectedDate)".changeDateFormateddMMYYYY
            self.notificationFilter["date"] = "\(selectedDate)"
            DispatchQueue.main.async {
                self.tableViewFilter.reloadData()
            }
        }
    }
    
    
}
class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet var buttonSelect:UIButton!
    @IBOutlet var lblName:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }
}
