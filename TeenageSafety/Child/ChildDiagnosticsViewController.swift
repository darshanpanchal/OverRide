//
//  ChildDiagnosticsViewController.swift
//  TeenageSafety
//
//  Created by user on 20/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ChildDiagnosticsViewController: UIViewController {

    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var lblTitle:UILabel!
    
    
    @IBOutlet var tableViewDiagnostics:UITableView!
    
    var objChildID:String?
    
    var currentChildDignostics:ChildDiagnostics?
    
    var childVehicleDiagnosis:[String:Any] = [:]
    
    var isForChild:Bool = false
    
    var attributesNormal: [NSAttributedString.Key: Any] =
        [NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#363636")]
        
    var attributesColor: [NSAttributedString.Key: Any] =
        [NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 12)!, NSAttributedString.Key.foregroundColor: kThemeColor]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    // MARK: - Setup Methods
    func setup(){
        self.configureTableView()
        //getVehicle Diagnosis
        if let childID = self.objChildID{
            self.getVehicleDiagnosisRequestAPI(objChildID: childID)
        }
        if isForChild{
            self.getVehicleDiagnosisRequestAPI(objChildID: "")
        }
        self.childVehicleDiagnosis["general"] = "General"
        self.childVehicleDiagnosis["pending"] = "Stored Fault Codes"
        self.childVehicleDiagnosis["permanent"] = "Pending Fault Codes"
        self.childVehicleDiagnosis["stored"] = "Permanent Fault Codes"
        
    }
    func configureTableView(){
        //ParentChildSummaryTableViewCell
        self.tableViewDiagnostics.rowHeight = UITableView.automaticDimension
        self.tableViewDiagnostics.estimatedRowHeight = 150.0
        let objNib = UINib.init(nibName: "ChildDiagnosticsTableViewCell", bundle: nil)
        self.tableViewDiagnostics.register(objNib, forCellReuseIdentifier: "ChildDiagnosticsTableViewCell")
        self.tableViewDiagnostics.delegate = self
        self.tableViewDiagnostics.dataSource = self
        self.tableViewDiagnostics.reloadData()
        self.tableViewDiagnostics.allowsSelection = true
        self.tableViewDiagnostics.layoutIfNeeded()
        
    }
    
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.popToBackViewController()
        }
    }
    // MARK: - API Request Methods
    func getVehicleDiagnosisRequestAPI(objChildID:String){
        var getChildVehicleDiagnosisParameters:[String:Any] = [:]
        getChildVehicleDiagnosisParameters["id"] = "\(objChildID)"
        
        
        APIRequestClient.shared.sendRequest(requestType:(isForChild ? .GET : .POST) , queryString: (isForChild ? kChildDiagnostics: kParentGETChildVehicleDiag) , parameter:(isForChild ? nil : getChildVehicleDiagnosisParameters as [String:AnyObject]), isHudeShow: true, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String{
                DispatchQueue.main.async {
                    print(objSuccess)
                    if let successData:[String:Any] =  objSuccess["data"] as? [String:Any]{
                        var arrayPending:[Diagnostics] = []
                        if let arraypending = successData["pending"] as? [[String:Any]]{
                            for pending in arraypending{
                                let objDiagnostics = Diagnostics.init(code: "\(pending["code"] ?? "")", desc: "\(pending["desc"] ?? "")")
                                arrayPending.append(objDiagnostics)
                            }
                        }
                        var arrayPermanent:[Diagnostics] = []
                        if let arraypermanent = successData["permanent "] as? [[String:Any]]{
                            for permanent in arraypermanent{
                                let objDiagnostics = Diagnostics.init(code: "\(permanent["code"] ?? "")", desc: "\(permanent["desc"] ?? "")")
                                arrayPermanent.append(objDiagnostics)
                            }
                        }
                        var arrayStored:[Diagnostics] = []
                        if let arraystored = successData["stored"] as? [[String:Any]]{
                            for stored in arraystored{
                                let objDiagnostics = Diagnostics.init(code: "\(stored["code"] ?? "")", desc: "\(stored["desc"] ?? "")")
                                arrayStored.append(objDiagnostics)
                            }
                        }
                        if let objDTC = successData["DTC"],let distance = successData["distance"],let mil = successData["mil"]{
                            
                            self.currentChildDignostics = ChildDiagnostics.init(DTC: "\(objDTC)", distance: "\(distance)", mil: "\(mil)", pending: arrayPending, permanent: arrayPermanent, stored: arrayStored)
                            
                            DispatchQueue.main.async {
                                self.tableViewDiagnostics.reloadData()
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func popToBackViewController(){
        self.navigationController?.popViewController(animated: true)
    }


}
extension ChildDiagnosticsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.childVehicleDiagnosis.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "ChildDiagnosticsTableViewCell") as! ChildDiagnosticsTableViewCell
  
        if indexPath.item == 0{
            objCell.lblTitle.text = "\(self.childVehicleDiagnosis["general"] ?? "")"
            if let _ = self.currentChildDignostics{
                let malFunction = NSMutableAttributedString.init(string: "\nMalfunction Indicator Lamp (MIL) ", attributes: self.attributesNormal)
                let malFunctionStatus = NSMutableAttributedString.init(string: "\(self.currentChildDignostics!.mil)", attributes: self.attributesColor)
                let distance = NSMutableAttributedString.init(string: "\n\nDistance Traveled While MIL Is ON ", attributes: self.attributesNormal)
                let distanceAmount = NSMutableAttributedString.init(string: "\(self.currentChildDignostics!.distance)", attributes: self.attributesColor)
                let DTC = NSMutableAttributedString.init(string: "\n\nNumber Of Confirmed DTCs ", attributes: self.attributesNormal)
                let DTCCount = NSMutableAttributedString.init(string: "\(self.currentChildDignostics!.DTC)", attributes: self.attributesColor)
                malFunction.append(malFunctionStatus)
                malFunction.append(distance)
                malFunction.append(distanceAmount)
                malFunction.append(DTC)
                malFunction.append(DTCCount)
                objCell.lblDetail.attributedText = malFunction
                /*
                "\nMalfunction Indicator Lamp (MIL) \(self.currentChildDignostics!.mil) \n\nDistance Traveled While MIL Is ON \(self.currentChildDignostics!.distance) \n\nNumber Of Confirmed DTCs \(self.currentChildDignostics!.DTC)"*/
            }
        }else if indexPath.item == 1{
            objCell.lblTitle.text = "\(self.childVehicleDiagnosis["pending"] ?? "")"
            if let _ = self.currentChildDignostics{
                for objPending in self.currentChildDignostics!.pending{
                    objCell.lblDetail.text = "\n\(objPending.code) \n\(objPending.desc)"
                }
            }
        }else if indexPath.item == 2{
            objCell.lblTitle.text = "\(self.childVehicleDiagnosis["permanent"] ?? "")"
            if let _ = self.currentChildDignostics{
               for objPermanet in self.currentChildDignostics!.permanent{
                   objCell.lblDetail.text = "\n\(objPermanet.code) \n\(objPermanet.desc)"
               }
           }
        }else if indexPath.item == 3{
            objCell.lblTitle.text = "\(self.childVehicleDiagnosis["stored"] ?? "")"
            if let _ = self.currentChildDignostics{
               for objStored in self.currentChildDignostics!.stored{
                   objCell.lblDetail.text = "\n\(objStored.code) \n\(objStored.desc)"
               }
           }
        }else{
            objCell.lblTitle.text = ""
        }
        return objCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
struct Diagnostics {
    var code, desc:String
}
struct ChildDiagnostics {
    var DTC, distance, mil:String
    var pending, permanent, stored:[Diagnostics]
}
