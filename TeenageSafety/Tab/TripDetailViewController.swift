//
//  TripDetailViewController.swift
//  TeenageSafety
//
//  Created by user on 26/12/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import GoogleMaps

class TripDetailViewController: UIViewController {

    @IBOutlet var objMapView:GMSMapView!
    @IBOutlet var tripContainerView:TripContainerView!
    
    @IBOutlet var buttonGrade:UIButton!
    @IBOutlet var lblDriveGrade:UILabel!
    @IBOutlet var lblPercentage:UILabel!
    @IBOutlet var lblPerformanceType:UILabel!
    @IBOutlet var lblDistance:UILabel!
    @IBOutlet var lblDuration:UILabel!
    
    @IBOutlet var containerViewFromTo:UIView!
    
    @IBOutlet var lblFromLocation:UILabel!
    @IBOutlet var lblFromDuration:UILabel!
    
    @IBOutlet var lblToLocation:UILabel!
    @IBOutlet var lblToDuration:UILabel!
    
    
    @IBOutlet var overSpeedStarView:FloatRatingView!
    @IBOutlet var harshbreakStarView:FloatRatingView!
    @IBOutlet var rapidAccelarationStarView:FloatRatingView!
    @IBOutlet var idealStandbyStarView:FloatRatingView!
    
    var objChildTrip:ChildTrip?
    var zoom: Float = 15
    
    var bounds = GMSCoordinateBounds()
    var timerAnimation: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()

        //initial Setup
        self.setup()
    }
    // MARK: - Setup Methods
    func setup(){
        self.buttonGrade.clipsToBounds = true
        self.buttonGrade.layer.cornerRadius = 10.0
        //containerViewFromTo
        self.containerViewFromTo.clipsToBounds = true
        self.containerViewFromTo.layer.cornerRadius = 12.0
        self.containerViewFromTo.layer.borderColor = kThemeColor.cgColor
        self.containerViewFromTo.layer.borderWidth = 1.0
        
        //drawRouteOnMap
        self.drawRouteOnMap()
        //configure child trip
        self.configureTripDetail()
        
    }
    func drawRouteOnMap(){
        if let _ = self.objChildTrip{
            
            
            if self.objChildTrip!.route.count > 0,let objFirst = self.objChildTrip!.route.first,let objLast = self.objChildTrip!.route.last{
                
                let camera = GMSCameraPosition.camera(withLatitude:objFirst.latitude.toDouble() ?? 0.0, longitude: objFirst.longitude.toDouble() ?? 0.0, zoom: zoom)
                self.objMapView.animate(to: camera)
                self.addFromAndToLocationMarker(from: objFirst, to: objLast)
                
            }
            let path = GMSMutablePath()
            for objRoute in self.objChildTrip!.route{
                path.addLatitude(objRoute.latitude.toDouble() ?? 0.0, longitude: objRoute.longitude.toDouble() ?? 0.0)
            }
            
            let polyline = GMSPolyline(path: path)
            polyline.map = objMapView
            polyline.strokeWidth = 3.0
            polyline.strokeColor = UIColor.clear
            polyline.geodesic = true
            
            self.animatePolylinePath(path: path)
            
            //self.bounds = self.bounds.includingPath(path)
            //let update = GMSCameraUpdate.fit(self.bounds, withPadding: 250)
            //self.objMapView.animate(with: update)
            
            
            
        }
    }
    func configureTripDetail(){
         if let _ = self.objChildTrip{
            let font:UIFont? = UIFont(name: "Poppins-Regular", size:20)
            let subfont:UIFont? = UIFont(name: "Poppins-Regular", size:15)
            let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(objChildTrip!.grade)", attributes: [.font:font!])
            attString.setAttributes([.font:subfont!,.baselineOffset:10], range: NSRange(location:1,length:1))
            self.lblDriveGrade.attributedText = attString
            self.lblPerformanceType.text = self.objChildTrip!.performance_type
            self.lblDistance.text = "Distance \(self.objChildTrip!.distance)"
            self.lblDuration.text = "Duration \(self.objChildTrip!.duration)"
            self.lblFromLocation.text = self.objChildTrip!.from
            self.lblFromDuration.text = self.objChildTrip!.from_time
            self.lblToLocation.text = self.objChildTrip!.to
            self.lblToDuration.text = self.objChildTrip!.to_time
            
            self.overSpeedStarView.rating = self.objChildTrip!.over_speed.toDouble() ?? 0.0
            self.harshbreakStarView.rating = self.objChildTrip!.harsh_break.toDouble() ?? 0.0
            self.idealStandbyStarView.rating = self.objChildTrip!.ideal_standby.toDouble() ?? 0.0
            self.rapidAccelarationStarView.rating = self.objChildTrip!.rapid_acceleration.toDouble() ?? 0.0
            
        }
    }
    func animatePolylinePath(path: GMSMutablePath) {
        
        var pos: UInt = 0
        var animationPath = GMSMutablePath()
        let animationPolyline = GMSPolyline()
        self.timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.003, repeats: true) { timer in
            
            if(pos >= path.count()){
                pos = 0
//                animationPath = GMSMutablePath()
//                animationPolyline.map = nil
                self.timerAnimation.invalidate()
                return
            }
            animationPath.add(path.coordinate(at: pos))
            animationPolyline.path = animationPath
            animationPolyline.strokeColor = UIColor.black
            animationPolyline.strokeWidth = 3
            animationPolyline.map = self.objMapView
            pos += 1
        }
    }
    func addFromAndToLocationMarker(from:TripRoute,to:TripRoute){
        let frommarker: GMSMarker = GMSMarker() // Allocating Marker
        let objFromImage = UIImage(named: "from_location")
        //frommarker.icon = UIImage(named: "from_location") // Marker icon
        let objFromImageView = UIImageView.init(image: objFromImage)
        objFromImageView.frame = CGRect.init(x: 0, y: 0, width: 25, height: 32)
        frommarker.iconView = objFromImageView//UIImageView.init(image: objFromImage)
        frommarker.appearAnimation = .pop // Appearing animation. default
        frommarker.position = CLLocationCoordinate2D.init(latitude: from.latitude.toDouble() ?? 0.0, longitude: from.longitude.toDouble() ?? 0.0)
        DispatchQueue.main.async { // Setting marker on mapview in main thread.
            frommarker.map = self.objMapView // Setting marker on Mapview
        }
        
        let tomarker: GMSMarker = GMSMarker() // Allocating Marker
        let objToImage = UIImage(named: "to_location")
//        tomarker.icon = UIImage(named: "to_location") // Marker icon
        let objToImageView = UIImageView.init(image: objToImage)
        objToImageView.frame = CGRect.init(x: 0, y: 0, width: 25, height: 32)
        tomarker.iconView = objToImageView//UIImageView.init(image: objFromImage)
        tomarker.appearAnimation = .pop // Appearing animation. default
        tomarker.position = CLLocationCoordinate2D.init(latitude: to.latitude.toDouble() ?? 0.0, longitude: to.longitude.toDouble() ?? 0.0)
        DispatchQueue.main.async { // Setting marker on mapview in main thread.
            tomarker.map = self.objMapView // Setting marker on Mapview
        }
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
class TripContainerView:UIView{
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners([.topLeft,.topRight], radius: 15.0)
    }
}
extension String
{
    /// EZSE: Converts String to Double
    public func toDouble() -> Double?
    {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
}
extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
}
