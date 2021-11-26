//
//  WebLoadViewController.swift
//  Lisaslaw
//
//  Created by user on 31/10/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import WebKit

class WebLoadViewController: UIViewController {

    @IBOutlet var navigationTitleImage:UIImageView!
    @IBOutlet var lblTitle:UILabel!
    
    @IBOutlet var webView:WKWebView!
    

    lazy var objURLString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let objURL = URL.init(string: objURLString){
            self.webView.navigationDelegate = self
            self.webView.load(URLRequest(url: objURL))
        }
        self.webView.allowsBackForwardNavigationGestures = true
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
extension WebLoadViewController:WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHud.hide()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ProgressHud.show()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ProgressHud.hide()
    }

}
