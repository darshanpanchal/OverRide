//
//  MapViewController.swift
//  TeenageSafety
//
//  Created by user on 31/10/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import MaterialShowcase

class MapViewController: UIViewController {

    
    @IBOutlet var objMapView:GMSMapView!
    
    @IBOutlet var childCollectionView:UICollectionView!
    var arrayOfChild:[ChildModel] = []
    @IBOutlet var buttonSetting:UIButton!
    @IBOutlet var blurView:UIView!
    var zoom: Float = 15

    var arrayOfChildPosition:[ChildPosition] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        self.setup()

    }
    
    func displayShowCase() {
        self.view.layoutIfNeeded()
        let showcase = MaterialShowcase()
        showcase.targetHolderRadius = 30.0
        showcase.setTargetView(view: self.buttonSetting)
        showcase.backgroundViewType = .full
        showcase.primaryText = ""
        showcase.primaryTextFont = UIFont.init(name:"Avenir-Heavy", size: 30.0)//CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        showcase.secondaryText = ""
        showcase.secondaryTextFont = UIFont.init(name:"Avenir-Heavy", size: 20.0)
        showcase.delegate = self
        showcase.shouldSetTintColor = true // It should be set to false when button uses image.
        showcase.backgroundPromptColor = .clear//UIColor.black.withAlphaComponent(0.1)
        showcase.backgroundPromptColorAlpha = 0.0
        showcase.isTapRecognizerForTargetView = false
        showcase.show(completion: {
        })

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //get parent child list request
        self.getParentChildListAPI()
        //get child track position request
        self.getParentChildTrackPositionAPIRequest()
        guard let _ =  kUserDefault.value(forKey: kShowCaseForAddChild) else {
            self.presentAddChildHint()
            return
        }
    }
    /*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }*/
    
    // MARK: - Custom Methods
    fileprivate func setup() {
        //configure google map view
        self.configureGoogleMap()
        //add custom marker
       // self.loadMapView()
        // Do any additional setup after loading the view.
        self.configureChildCollectionView()
    }
    func configureGoogleMap(){
        self.objMapView.delegate = self
        self.objMapView.isMyLocationEnabled = true
        self.objMapView.settings.myLocationButton = false
        self.objMapView.padding = UIEdgeInsets.init(top: 0, left: 0, bottom: 100, right: 0)
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: zoom)
        self.objMapView.camera = camera
    }
    func loadMapView(){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        let objView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
        let markerView = UIImageView.init(image: UIImage.init(named: "marker"))
        markerView.frame = CGRect.init(x: 0, y: 0, width: 80, height: 80)
        
        markerView.contentMode = .scaleAspectFit
        objView.addSubview(markerView)
        let profileImageView = UIImageView()//.init(image: UIImage.init(named: "patric"))
        profileImageView.frame = CGRect.init(x: 40-25.5, y: 7, width: 52.0, height: 52.0)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        let objURL = URL.init(string: "")
        profileImageView.sd_setImage(with: objURL, placeholderImage:UIImage.init(named: "user_placeholder") , options: .refreshCached, context: nil)
      
        objView.addSubview(profileImageView)
//        objView.backgroundColor = UIColor.white
        let objImge = UIImageView.init(image: self.imageWithView(view: objView))
        marker.iconView = objImge
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = self.objMapView
    }
    func addChildMarker(objChild:ChildModel,index:Int){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        let objView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 58, height: 58))
        let markerView = UIImageView.init(image: UIImage.init(named: "marker"))
        markerView.frame = CGRect.init(x: 0, y: 0, width: 58, height:58)
        markerView.contentMode = .scaleAspectFit
        objView.addSubview(markerView)
        let profileImageView = UIImageView()//.init(image: UIImage.init(named: "patric"))
        profileImageView.frame = CGRect.init(x: 8.5, y: 3.5, width: 40, height: 40)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20.0
        profileImageView.clipsToBounds = true
        marker.accessibilityValue = "\(index)"
        if let objURL = URL.init(string: objChild.image){
            profileImageView.sd_setImage(with: objURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, progress: nil) { (image, error, type, url) in
                objView.addSubview(profileImageView)
                let objImge = UIImageView.init(image: self.imageWithView(view: objView))
                marker.iconView = objImge
                marker.map = self.objMapView
                
            }
        }
    }
    func addChildMarkerWithChildPosition(objChildPosition:ChildPosition,index:Int){
        
        let marker = GMSMarker()
        let lat = objChildPosition.position.latitude
        let long = objChildPosition.position.longitude
        if lat.count > 0, long.count > 0{
            marker.position = CLLocationCoordinate2D(latitude: lat.toDouble() ?? 0.0, longitude: long.toDouble() ?? 0.0)
        }
        if let app = UIApplication.shared.delegate as? AppDelegate,let currentChildID = app.currentChildID,currentChildID == objChildPosition.id{
            if lat.count > 0, long.count > 0{
                let camera = GMSCameraPosition.camera(withLatitude:  lat.toDouble() ?? 0.0, longitude: long.toDouble() ?? 0.0, zoom: zoom)
                self.objMapView.camera = camera
                self.objMapView.animate(to: camera)
            }
        }
        let objView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 58, height: 58))
        let markerView = UIImageView.init(image: UIImage.init(named: "marker"))
        markerView.frame = CGRect.init(x: 0, y: 0, width: 58, height:58)
        markerView.contentMode = .scaleAspectFit
        objView.addSubview(markerView)
        let profileImageView = UIImageView()//.init(image: UIImage.init(named: "patric"))
        profileImageView.frame = CGRect.init(x: 8.5, y: 3.5, width: 40, height: 40)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20.0
        profileImageView.clipsToBounds = true
        marker.accessibilityValue = "\(index)"
        if let objURL = URL.init(string: objChildPosition.image){
            profileImageView.sd_setImage(with: objURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, progress: nil) { (image, error, type, url) in
                objView.addSubview(profileImageView)
                let objImge = UIImageView.init(image: self.imageWithView(view: objView))
                marker.iconView = objImge
                marker.map = self.objMapView
                
            }
        }
    }
    func imageWithView(view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    func configureChildCollectionView(){
        self.childCollectionView.delegate = self
        self.childCollectionView.dataSource = self
        self.childCollectionView.reloadData()
        self.childCollectionView.allowsSelection = true
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonPofileSelector(sender:UIButton){
        self.pushToParentProfileViewController()
    }
    @IBAction func buttonSettingSelector(sender:UIButton){
        if let appDel = UIApplication.shared.delegate as? AppDelegate{
            if !appDel.isSprint1Only{
                self.pushToSettingViewController()
            }
        }
        
    }
    @IBAction func btnZoomIn(_ sender: Any) {
        zoom = zoom + 1
        self.objMapView.animate(toZoom: zoom)
    }
    
    @IBAction func btnZoomOut(_ sender: Any) {
        zoom = zoom - 1
        self.objMapView.animate(toZoom: zoom)
    }
     @IBAction func gotoMyLocationAction(sender: UIButton){
        guard let lat = self.objMapView.myLocation?.coordinate.latitude,
            let lng = self.objMapView.myLocation?.coordinate.longitude else { return }
        
        let camera = GMSCameraPosition.camera(withLatitude: lat ,longitude: lng , zoom: zoom)
        self.objMapView.animate(to: camera)
    }
    @IBAction func buttonAddSelector(sender:UIButton){
        self.pushToAddChildViewController()
    }
    @IBAction func buttonAddChildSelector(sender:UIButton){
        self.pushToAddChildViewController()
    }
    @IBAction func buttonChildSelector(sender:UIButton){
        if let app = UIApplication.shared.delegate as? AppDelegate{
            let objChild = self.arrayOfChild[sender.tag - 1]
            app.currentChildID = objChild.id
            self.saveSelectedChild(id: app.currentChildID ?? "0")
            self.childCollectionView.reloadData()
            
            let arrayChildPosition = self.arrayOfChildPosition.filter{$0.id == objChild.id}
                 if arrayChildPosition.count > 0,let firstPosition = arrayChildPosition.first{
                     let lat = firstPosition.position.latitude
                     let long = firstPosition.position.longitude
                          if lat.count > 0, long.count > 0{
                              let camera = GMSCameraPosition.camera(withLatitude:  lat.toDouble() ?? 0.0, longitude: long.toDouble() ?? 0.0, zoom: zoom)
                              self.objMapView.camera = camera
                              self.objMapView.animate(to: camera)
                          }
                 }
        }
    }
    func saveSelectedChild(id:String){
        UserDefaults.standard.set(id, forKey: "currentChild")
        UserDefaults.standard.synchronize()
    }
    @IBAction func buttonMissionMapSelector(sender:UIButton){
        self.presentMissionView()
    }
    // MARK: - API
    func getParentChildListAPI(){
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: kParentChildList, parameter:nil, isHudeShow: false, success: { (responseSuccess) in
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let successData = objSuccess["data"] as? [String:Any]{
                if let arrayChild:[[String:Any]] = successData["child"] as? [[String:Any]]{
                    self.arrayOfChild.removeAll()
                    for var childJSON:[String:Any] in arrayChild{
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
                    self.configureMapMarkerWithChildList()
                }
                DispatchQueue.main.async {
                    if let app = UIApplication.shared.delegate as? AppDelegate{
                        if let objID = app.currentChildID{
                            
                        }else{
                            if self.arrayOfChild.count > 0{
                                app.currentChildID = self.arrayOfChild.first!.id
                                self.saveSelectedChild(id: app.currentChildID ?? "0")
                            }
                            
                        }
                    }
                    self.childCollectionView.reloadData()
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
    func configureMapMarkerWithChildList(){
        /*
        DispatchQueue.main.async {
            for (index,objChild) in self.arrayOfChild.enumerated(){
                if index == 0{
                    self.addChildMarker(objChild: objChild, index: index)
                }
                
            }
        }*/
    }
    func configureGoogleMarkerWithChildList(){
        print(self.arrayOfChildPosition)
        DispatchQueue.main.async {
            self.objMapView.clear()
            for (index,childPosition) in self.arrayOfChildPosition.enumerated(){
                self.addChildMarkerWithChildPosition(objChildPosition: childPosition, index: index)
            }
        }
    }
    //get child location API request
    func getParentChildTrackPositionAPIRequest(){
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: kParentChildTrackPosition, parameter:nil, isHudeShow: false, success: { (responseSuccess) in
            
            if let objSuccess = responseSuccess as? [String:Any],let _ :String = objSuccess["message"] as? String,let arraySuccessData:[[String:Any]] = objSuccess["data"] as? [[String:Any]]{
                self.arrayOfChildPosition.removeAll()
                for objChildPosition in arraySuccessData{
                    if let objPosition:[String:Any] = objChildPosition["position"] as? [String:Any]{
                        let objPositionDetail = ChildPositionDetail.init(battery: "\(objPosition["battery"] ?? "")", engine_status: "\(objPosition["engine_status"] ?? "")", last_track_at: "\(objPosition["last_track_at"] ?? "")", latitude: "\(objPosition["latitude"] ?? "")", location: "\(objPosition["location"] ?? "")", longitude: "\(objPosition["longitude"] ?? "")", speed: "\(objPosition["speed"] ?? "")")
                        let objChildDetail = ChildPosition.init(id: "\(objChildPosition["id"] ?? "")", image: "\(objChildPosition["image"] ?? "")", name: "\(objChildPosition["name"] ?? "")", phone: "\(objChildPosition["phone"] ?? "")", email: "\(objChildPosition["email"] ?? "")", dob: "\(objChildPosition["dob"] ?? "")", country_code: "\(objChildPosition["country_code"] ?? "")", access_token: "\(objChildPosition["access_token"] ?? "")", gender: "\(objChildPosition["gender"] ?? "")", position: objPositionDetail)
                        self.arrayOfChildPosition.append(objChildDetail)
                    }
                }
                //configure google markers
                self.configureGoogleMarkerWithChildList()
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
    func pushToParentProfileViewController(){
        if let objParentProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentProfileViewController") as? ParentProfileViewController{
            objParentProfileViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objParentProfileViewController, animated: true)
        }
    }
    func pushToSettingViewController(){
        if let objParentSettingViewController = self.storyboard?.instantiateViewController(withIdentifier: "ParentSettingViewController") as? ParentSettingViewController{
            objParentSettingViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objParentSettingViewController, animated: true)
        }
    }
    func pushToAddChildViewController(){
        if let objAddChildViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddChildViewController") as? AddChildViewController{
            objAddChildViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objAddChildViewController, animated: true)
        }
    }
    func presentAddChildHint(){
        if let objAddChildViewController = self.storyboard?.instantiateViewController(withIdentifier: "MaterialShowCaseViewController") as? MaterialShowCaseViewController{
            objAddChildViewController.modalPresentationStyle = .overCurrentContext
            objAddChildViewController.objDelegate = self
            self.tabBarController?.present(objAddChildViewController, animated: false, completion: nil)
        }
    }
    func presentMissionView(){
        if let objMIssionStatementViewController = self.storyboard?.instantiateViewController(withIdentifier: "MIssionStatementViewController") as? MIssionStatementViewController{
            objMIssionStatementViewController.modalPresentationStyle = .overCurrentContext
            self.tabBarController?.present(objMIssionStatementViewController, animated: false, completion: nil)
        }
    }
}
extension MapViewController:MaterialDelegate{
    func addChildSelector() {
        self.pushToAddChildViewController()
    }
}
extension MapViewController:GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
       
    }
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        let objNIBView:ChildMapInfo = UIView.fromNib()
        if let strIndex = marker.accessibilityValue,let index = Int(strIndex),self.arrayOfChildPosition.count > index{
            let objChild = self.arrayOfChildPosition[index]
            objNIBView.lblName.text = objChild.name
            objNIBView.lblPlaceName.text = objChild.position.location
            objNIBView.lblBattary.text = objChild.position.battery
            objNIBView.lblTime.text = objChild.position.last_track_at
            objNIBView.lblSpeed.text = objChild.position.speed
        }
        objNIBView.clipsToBounds = true
        objNIBView.layer.cornerRadius = 12.0
        return objNIBView
    }
    
}
extension MapViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrayOfChild.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let childCell:ChildCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildCollectionViewCell", for: indexPath) as! ChildCollectionViewCell
        childCell.buttonAddChild.isHidden = indexPath.item != 0
        childCell.buttonChild.isHidden = indexPath.item == 0
        childCell.buttonAddChild.addTarget(self, action: #selector(buttonAddSelector(sender:)), for: .touchUpInside)
        childCell.buttonChild.tag = indexPath.item
        childCell.buttonChild.addTarget(self, action: #selector(buttonChildSelector(sender:)), for: .touchUpInside)
        
        if indexPath.item > 0{
            let objChild = self.arrayOfChild[indexPath.item - 1]
             let objURL = URL.init(string: objChild.image)
             childCell.buttonChild.sd_setImage(with: objURL, for: .normal, placeholderImage: UIImage.init(named: "user_placeholder") , options: .refreshCached, progress: nil, completed: nil)
            childCell.buttonChild.imageView?.contentMode = .scaleAspectFill
            childCell.buttonChild.layer.borderWidth = 2.0
            childCell.buttonChild.layer.borderColor = (self.getIndexOfCurrentChild(child: objChild)) ? kThemeColor.cgColor : UIColor.clear.cgColor
            
        }
        return childCell
    }
    func getIndexOfCurrentChild(child:ChildModel)->Bool{
        if let app = UIApplication.shared.delegate as? AppDelegate{
            if let objID = app.currentChildID,objID == child.id{
                return true
            }else{
                return false
            }
        }
        return false
    }
    /*
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
     return CGSize.init(width: UIScreen.main.bounds.width/3, height:  UIScreen.main.bounds.width/2.5)//collectionView.bounds.size.width*0.5+50+30)
     }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
     if let user = User.getUserFromUserDefault(){
     guard user.userType == .admin else{
     return CGSize.zero
     }
     }
     return CGSize.init(width: collectionView.bounds.width, height: 85.0)
     }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
     return UIEdgeInsets.zero//UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
     }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
     return 0//15.0
     }*/
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0{
            self.pushToAddChildViewController()
        }else{
            if let app = UIApplication.shared.delegate as? AppDelegate{
                let objChild = self.arrayOfChild[indexPath.item - 1]
                app.currentChildID = objChild.id
                self.saveSelectedChild(id: app.currentChildID ?? "0")
                self.childCollectionView.reloadData()
                
                let arrayChildPosition = self.arrayOfChildPosition.filter{$0.id == objChild.id}
                if arrayChildPosition.count > 0,let firstPosition = arrayChildPosition.first{
                    let lat = firstPosition.position.latitude
                    let long = firstPosition.position.longitude
                         if lat.count > 0, long.count > 0{
                             let camera = GMSCameraPosition.camera(withLatitude:  lat.toDouble() ?? 0.0, longitude: long.toDouble() ?? 0.0, zoom: zoom)
                             self.objMapView.camera = camera
                             self.objMapView.animate(to: camera)
                         }
                }
            }
        }
    }
}
extension MapViewController: MaterialShowcaseDelegate {
    func showCaseWillDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        //kUserDefault.set(true, forKey: kShowCaseForLocationButton)
    }
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
    }
}
struct ChildPositionDetail {
    var battery, engine_status, last_track_at, latitude, location, longitude, speed:String
}
struct ChildPosition {
    let id, image, name, phone, email, dob, country_code, access_token, gender: String
    let position:ChildPositionDetail
}
