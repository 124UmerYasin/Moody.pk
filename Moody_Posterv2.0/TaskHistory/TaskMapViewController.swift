//
//  TaskMapViewController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit
import GoogleMaps

class TaskMapViewController: UIViewController {
    
    //MARK: Variables
    var mapView = GMSMapView()
    let path = GMSMutablePath()
    static var coordinates = [String]()
    var previousCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    static var pickupCoordinates = [Double]()
    var camera = GMSCameraPosition()
    
    var marker = GMSMarker()
    let markerView = UIImageView(image: UIImage(named: "bikeIcon22"))
    var timer:Timer?
    var index:UInt = 0

    
    override func viewDidLoad(){
        super .viewDidLoad()
        
        setupNavigationBar()
        setInitialCamera()
        
        tabBarController?.tabBar.isHidden = true
        
        tabBarController?.tabBar.selectedItem?.title = "Task History"
        
        marker = GMSMarker(position: self.path.coordinate(at:self.index))
        marker.iconView = markerView
        marker.map = self.mapView
        
        drawPathForTask()
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:
                       #selector(timerTriggered), userInfo: nil, repeats: true)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Task History Map", comment: "")
    }
    
    //MARK: Sets initial View of Map
    //. sets camera postion
    //. sets marker postion
    func setInitialCamera(){
        
        let latLong = TaskMapViewController.coordinates[0].split(separator: ",")
        let initialLatitude = Double(latLong[0])!
        var initialLongitude = Double(latLong[1].split(separator: " ")[0])!
        
        initialLongitude = initialLongitude + 0.0001
        
        camera = GMSCameraPosition.camera(withLatitude: initialLatitude, longitude: initialLongitude, zoom: 14.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
        setMarkerPosition(longitude: TaskMapViewController.pickupCoordinates[1], latitude: TaskMapViewController.pickupCoordinates[0], title: NSLocalizedString("Pickup Location", comment: ""), image: "PickupLocation")
        setMarkerPosition(longitude: initialLongitude, latitude: initialLatitude, title: NSLocalizedString("Tasker Initial Location", comment: ""), image: "StartLocation")
        
    }

    //MARK: Draw path of task
    //. path is created of tasker location saved in static array of coordinates
    //. polyline is drawn on path
    func drawPathForTask(){
        
        var latitude = Double()
        var longitude = Double()
        
        for coord in TaskMapViewController.coordinates {
            
            let latLong = coord.split(separator: ",")
            latitude = Double(latLong[0])!
            longitude = Double(latLong[1].split(separator: " ")[0])!
            
            let distanceInMeters = getDistance(latitude: latitude, longitude: longitude)
            
            if(distanceInMeters > 20){
                path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
        
        setMarkerPosition(longitude: longitude, latitude: latitude, title: NSLocalizedString("Tasker Ending Location", comment: ""), image: "DropoffLocation" )
        drawPolylinePath()
        
    }
   
    //MARK: Marker postion are set from received coordinates in method
    func setMarkerPosition(longitude: Double, latitude: Double, title: String, image: String){
        
        let marker = GMSMarker()
        let markerView = UIImageView(image: UIImage(named: image))
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.iconView = markerView
        marker.map = mapView
        
    }
    
    //MARK: Draws polyine
    func drawPolylinePath(){
       
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 7.0
        polyline.geodesic = true
        let systemBlue = GMSStrokeStyle.solidColor(.systemBlue)
        polyline.spans = [GMSStyleSpan(style: systemBlue)]
        polyline.map = mapView
        
    }
    
    //MARK: Distance is calucalted between previous coordinates and distance in meters in returned
    func getDistance(latitude: Double, longitude: Double) -> Double {
        
        let coordinate0 = CLLocation(latitude: previousCoordinate.latitude, longitude: previousCoordinate.longitude)
        let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = coordinate0.distance(from: coordinate1)
        
        if(distanceInMeters > 20){
            
            previousCoordinate.latitude = latitude
            previousCoordinate.longitude = longitude
            
        }
        
        return distanceInMeters
        
    }
    
    
    //MARK: timer is started after the movement of marker on polylines
    @objc func timerTriggered() {

        if self.index < self.path.count() {

            CATransaction.begin()
            CATransaction.setAnimationDuration(0.1)
            self.marker.position = self.path.coordinate(at:index)
            let degrees = getBearingBetweenTwoPoints1(point1: self.path.coordinate(at:index), point2: self.path.coordinate(at:index+1))
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.rotation = degrees
            CATransaction.commit()
            self.index += 1

          } else {
            
            marker.map = .none
            timer!.invalidate()
              timer = nil

          }

      }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }

    func getBearingBetweenTwoPoints1(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {

        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)

        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansToDegrees(radians: radiansBearing)
    }
    
    
}
