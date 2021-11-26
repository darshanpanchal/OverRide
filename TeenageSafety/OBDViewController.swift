//
//  OBDViewController.swift
//  TeenageSafety
//
//  Created by user on 04/10/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import OBD2

class OBDViewController: UIViewController {
    
    let obdObject = OBD2()

    @IBOutlet var txtOBDUITextView:UITextView!
    var strOBDData:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "OBD SWift"
        self.obdConnectionMethods()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    // MARK: - OBD Connection Methods
    func obdConnectionMethods(){
        self.obdObject.connect { (success, error) in
            print(success)
            print(error?.localizedDescription)
        }
        
        let observer = Observer<Command.Mode01>()
        
        observer.observe(command: .pid(number: 12)) { (descriptor) in
            let respStr = descriptor?.shortDescription
            print("Observer : \(String(describing: respStr))")
        }
        ObserverQueue.shared.register(observer: observer)
        
        obdObject.stateChanged = { (state) in
            
            OperationQueue.main.addOperation { [weak self] in
                self?.onOBD(change: state)
            }
        }
        /*
        self.obdObject.connect { [weak self] (success, error) in
            
            if let error = error {
                ShowToast.show(toatMessage:"OBD connection failed with \(error)" )
                //print("OBD connection failed with \(error)")
            } else {
                //perform something
            }
        }*/
    }
    func onOBD(change state:ScanState) {
        switch state {
        case .none:
            print("Not Connected")
            //indicator.stopAnimating()
           // statusLabel.text = "Not Connected"
           // updateUI(connected: false)
            break
        case .connected:
            print("Connected")
            //indicator.stopAnimating()
            //statusLabel.text = "Connected"
            //updateUI(connected: true)
            break
        case .openingConnection:
            print("Opening connection")
//            connectButton.isHidden = true
//            indicator.startAnimating()
//            statusLabel.text = "Opening connection"
            break
        case .initializing:
            print("Initializing")
            //statusLabel.text = "Initializing"
            break
        }
    }

}
