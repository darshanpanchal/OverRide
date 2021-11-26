//
//  FilterDateHeaderView.swift
//  TeenageSafety
//
//  Created by user on 11/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
protocol FilterHeaderViewDelegate {
    func updateFilterParameters(filterParameters:[String:Any])
}
class FilterDateHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var txtDate:UITextField!
    
    var fromDatePicker:UIDatePicker = UIDatePicker()
    var fromDatePickerToolbar:UIToolbar = UIToolbar()
    var filerDateDelegate:FilterHeaderViewDelegate?
    
    var filterParameters:[String:Any] = [:]
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
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
        
        
        self.txtDate.inputView = self.fromDatePicker
        self.txtDate.inputAccessoryView = self.fromDatePickerToolbar
    }
    @objc func doneFormDatePicker(){
        DispatchQueue.main.async {
            self.txtDate.resignFirstResponder()
        }
        //self.txtDate.text = "\(self.fromDatePicker.date.yyyyMMdd)"
        self.filterParameters["dob"] = "\(self.fromDatePicker.date.yyyyMMdd)"
        if let _ = self.filerDateDelegate{
            self.filerDateDelegate!.updateFilterParameters(filterParameters: self.filterParameters)
        }
    }
    @objc func cancelFormDatePicker(){
        DispatchQueue.main.async {
            self.txtDate.resignFirstResponder()
        }
    }

}
