//
//  CountryPickerViewController.swift
//  TeenageSafety
//
//  Created by user on 27/11/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
protocol CountryPickerDelegate {
    func didselectCountryCodewith(country:CountryCode)
}
class CountryPickerViewController: UIViewController {

    var arrayOfCountry:[CountryCode] = []
    
    @IBOutlet var tableViewCountryCode:UITableView!
    
    @IBOutlet var countryListContainer:UIView!
    
    var delegate:CountryPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup
        self.setUp()
        //Configure TableView
        self.configureTableView()
        //Read JSON File
        self.readJSONFile()
    }
    func setUp(){
        self.countryListContainer.layer.cornerRadius = 6.0
        self.countryListContainer.clipsToBounds = true
    }
    func readJSONFile(){
        if let path = Bundle.main.path(forResource: "country", ofType: "json"){
            do {
                let objData = try NSData.init(contentsOfFile: path, options: .mappedIfSafe)
                if let jsonReusult = try JSONSerialization.jsonObject(with: objData as Data, options: .mutableContainers) as? [Any]{
                    if let array:[[String:Any]] = jsonReusult as? [[String:Any]]{
                        self.arrayOfCountry.removeAll()
                        for objCountry in array{
                            let objCountryCode = CountryCode.init(countryName:"\(objCountry["name"]!)", countryCode:"\(objCountry["code"]!)", dialCode: "\(objCountry["dial_code"]!)")
                            self.arrayOfCountry.append(objCountryCode)
                        }
                        DispatchQueue.main.async {
                            self.tableViewCountryCode.reloadData()
                        }
                    }
                }
            }catch{
                
            }
        }
    }
    func configureTableView(){
        self.tableViewCountryCode.allowsSelection = true
        self.tableViewCountryCode.delegate = self
        self.tableViewCountryCode.dataSource = self
        self.tableViewCountryCode.reloadData()
    }
    @IBAction func buttonFullScreenSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension CountryPickerViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfCountry.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCountry = self.arrayOfCountry[indexPath.row]
        let objCell = UITableViewCell()
        objCell.textLabel?.numberOfLines = 0
        objCell.textLabel?.text = "\(objCountry.countryName) (\(objCountry.dialCode))"
        return objCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objCountry = self.arrayOfCountry[indexPath.row]
        if let _ = self.delegate{
            self.delegate!.didselectCountryCodewith(country: objCountry)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
struct CountryCode {
    let countryName,countryCode,dialCode:String
}
