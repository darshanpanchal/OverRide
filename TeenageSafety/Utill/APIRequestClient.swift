//
//  APIRequestClient.swift
//  TeenageSafety
//
//  Created by user on 19/11/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import Alamofire

let kNoInternetError = Vocabulary.getWordFromKey(key:"NoInternet")
let kUserDetail = "UserDetail"
let kChildDetail = "ChildDetail"
let kParentDetail = "ParentDetail"
let kUserDefault = UserDefaults.standard

let kParentLogin = "parent/login"
let kParentSignUp = "parent/signup"
let kVersion = "v1/"
let kParentProfile = "parent/profile"
let kParentChildList = "parent/getchild"
let kParentAddChild = "parent/addchild"
let kParentDeleteChild = "parent/childdelete"
let kParentUpdateProfile = "parent/update"
let kParentGETChildProfile = "parent/childprofile"
let kParentChildUpdate = "parent/childupdate"
let kParentForgotPassword = "parent/forgotpassword"
let kParentChangePassword = "parent/changepassword"
let kParentGETNotification = "parent/notificationsetting"
let kParentUpdateNotificationSetting = "parent/notificationsetting/change"
let kParentGETChildApplication = "parent/child/application"
let kParentChildAppAccess = "parent/child/appaccess"
let kParentGETNotificationList = "parent/notifications"
let kParentChildSummaryList = "parent/childsummarylist"
let kParentChildWeekSummary = "parent/childsummary"
let kParentChildReportList = "parent/childreportlist"
let kParentChildReport = "parent/childreport"
let kParentGETNotificationFilter = "parent/notificationfilter"
let kParentGETChildVehicleDiag = "parent/childdiagnostics"
let kParentChildTrackPosition = "parent/child/trackposition"

let kChildLogIn = "child/login"
let kParentChildChangePassword = "parent/childchangepassword"
let kChildGETApplication = "child/applications"
let kChildAppAccesss = "child/applications/request"
let kChildGETProfile = "child/profile"
let kChildUpdateProfile = "child/update"
let kChildSOS = "child/sos"
let kChildSummary = "child/summary"
let kChildReport = "child/report"
let kChildOBDConnect = "child/obdconnect"
let kChildBLEConnect = "child/bluetoothconnect"
let kChildDiagnostics = "child/diagnostics"
let kChildDevice = "child/device"
let kChildMDMStatus = "child/mdm/enrollment/status"

class APIRequestClient: NSObject {
    enum RequestType {
        case POST
        case GET
        case PUT
        case DELETE
        case PATCH
        case OPTIONS
    }
    static let shared:APIRequestClient = APIRequestClient()
    func cancelAllAPIRequest(json:Any?){
        
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
        if let url  = URL.init(string:kBaseURL){
            let task:URLSessionDataTask = URLSession.shared.dataTask(with:url)
            task.cancel()
        }
        if let _ = json{
            if let arrayFail = json as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                    ShowToast.show(toatMessage:"invalid access token")
                }
            }
        }
        
    }
    
   
    
    func useOfAPIRequest(){
        if let baseGETURL = URL(string:"https://postman-echo.com/get?foo1=bar1&foo2=bar2"){
            self.fetch(requestURL: baseGETURL, requestType: "GET", parameter: nil) { (result) in
                      switch result{
                      case .success(let response) :
                        print("Hello World \(response)")
                      case .failure(let error) :
                        print("Hello World \(error)")
                          
                      }
                  }
        }
      
    }
    enum CustomError:Error {
        case responseStatusError
        case nullDataError
    }
    //Send Request with ResultType<Success, Error>
    func fetch(requestURL:URL,requestType:String,parameter:[String:AnyObject]?,completion:@escaping (Result<Any>) -> () ){
        //Check internet connection as per your convenience
        //Check URL whitespace validation as per your convenience
        //Show Hud
        var urlRequest = URLRequest.init(url: requestURL)
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        urlRequest.timeoutInterval = 60
        urlRequest.httpMethod = String(describing: requestType)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        //Post URL parameters set as URL body
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                urlRequest.httpBody = parameterData
            }catch{
               //Hide hude and return error
                completion(.failure(error))
            }
        }
        //URL Task to get data
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            //Hide Hud
            //fail completion for Error
            if let objError = error{
                completion(.failure(objError))
            }
            //Validate for blank data and URL response status code
            if let objData = data,let objURLResponse = response as? HTTPURLResponse{
                //We have data validate for JSON and convert in JSON
                do{
                    let objResposeJSON = try JSONSerialization.jsonObject(with: objData, options: .mutableContainers)
                    //Check for valid status code 200 else fail with error
                    if objURLResponse.statusCode == 200{
                        completion(.success(objResposeJSON))
                    }
                }catch{
                    completion(.failure(error))
                }
            }
        }.resume()
    }
   
    //Post LogIn API
    func sendRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        
        let urlString = kBaseURL + kVersion + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
       
        if Parent.isParentLoggedIn,let objParent = Parent.getParentFromUserDefault(){
            request.setValue("Bearer \(objParent.parentAccessToken)", forHTTPHeaderField: "Authorization")
        }else if Child.isChildLoggedIn,let objChild = Child.getChildFromUserDefault(){
            request.setValue("Bearer \(objChild.childAccessToken)", forHTTPHeaderField: "Authorization")
        }
         /*if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id.count > 0{
                request.setValue("\(user.userrole_id)", forHTTPHeaderField: "roll_id")
            }
        }*/
 
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                //fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    
                    (httpStatus.statusCode == 200) ? success(json):fail(json)
                }
                catch{
                    //ShowToast.show(toatMessage: kCommonError)
                    //fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    func sendMDMAPIRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
           guard CommonClass.shared.isConnectedToInternet else{
               ShowToast.show(toatMessage: kNoInternetError)
               //fail(["Error":kNoInternetError])
               return
           }
           if isHudeShow{
               DispatchQueue.main.async {
                   ProgressHud.show()
               }
           }
           
           let urlString = kBaseURL + kVersion + (queryString == nil ? "" : queryString!)
           
           var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
           request.cachePolicy = .reloadIgnoringLocalCacheData
           request.timeoutInterval = 60
           request.httpMethod = String(describing: requestType)
           request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
           request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
          
           if let params = parameter{
               do{
                   let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                   request.httpBody = parameterData
               }catch{
                   DispatchQueue.main.async {
                       ProgressHud.hide()
                   }
                   ShowToast.show(toatMessage: kCommonError)
                   fail(["error":kCommonError])
               }
           }
           let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
               DispatchQueue.main.async {
                   ProgressHud.hide()
               }
               if error != nil{
                   ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                   //fail(["error":"\(error!.localizedDescription)"])
               }
               if let _ = data,let httpStatus = response as? HTTPURLResponse{
                   do{
                       let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                       
                       (httpStatus.statusCode == 200) ? success(json):fail(json)
                   }
                   catch{
                       //ShowToast.show(toatMessage: kCommonError)
                       //fail(["error":kCommonError])
                   }
               }else{
                   ShowToast.show(toatMessage: kCommonError)
                   fail(["error":kCommonError])
               }
           }
           task.resume()
       }
    //Upload Images
    func uploadImage(requestType:RequestType,queryString:String?,parameter:[String:AnyObject],imageData:Data?,isPDF:Bool = false,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            // fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + kVersion + (queryString == nil ? "" : queryString!)
        
        var rollId:String = ""
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id.count > 0{
                rollId = "\(user.userrole_id)"
            }
        }
        var headers: HTTPHeaders = ["Content-type": "multipart/form-data"]//,"X-API-KEY":kXAPIKey,"roll_id":"\(rollId)"]
        
        if Parent.isParentLoggedIn,let objParent = Parent.getParentFromUserDefault(){
            headers["Authorization"] = "Bearer \(objParent.parentAccessToken)"
            //request.setValue("Bearer \(objParent.parentAccessToken)", forHTTPHeaderField: "Authorization")
        }else if Child.isChildLoggedIn,let objChild = Child.getChildFromUserDefault(){
            headers["Authorization"] = "Bearer \(objChild.childAccessToken)"
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in parameter {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let _ = imageData{
                if isPDF{
                    multipartFormData.append(imageData!, withName: "file", fileName: "file.pdf", mimeType: "application/pdf")
                }else{
                    multipartFormData.append(imageData!, withName: "image", fileName: "image.png", mimeType: "image/png")
                }
                
            }
            
        }, usingThreshold: UInt64.init(), to: urlString, method:HTTPMethod(rawValue:"\(requestType)")!, headers: headers) { (result) in
            
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    if let objResponse = response.response,objResponse.statusCode == 200{
                        if let successResponse = response.value as? [String:Any]{
                            success(successResponse)
                        }
                    }else if let objResponse = response.response,objResponse.statusCode == 401{
                        self.cancelAllAPIRequest(json: response.value)
                    }else if let objResponse = response.response,objResponse.statusCode == 400{
                        if let failResponse = response.value as? [String:Any]{
                            fail(failResponse)
                        }
                    }else if let error = response.error{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(error.localizedDescription)")
                            fail(["error":"\(error.localizedDescription)"])
                        }
                    }else{
                        DispatchQueue.main.async {
                            if let failResponse = response.value as? [String:Any]{
                                fail(failResponse)
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(error.localizedDescription)")
                    fail(["error":"\(error.localizedDescription)"])
                }
            }
        }
    }
}
