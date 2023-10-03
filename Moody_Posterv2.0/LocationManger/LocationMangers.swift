//
//  LocationMangers.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 04/06/2021.
//

import Foundation
import UIKit
import CoreLocation

class LocationManagers : UIViewController,CLLocationManagerDelegate{
    
    static var locationSharesInstance = LocationManagers()
    var userLocation:CLLocation! = nil
    var locationManager: CLLocationManager?

    //MARK: Functions requests the user the permission to get current locations.
    func requestPermissionofLocation(){
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest

    }
    
    //MARK: Updates current location whenever the device is moved from the previous position
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
        }
    }
    
    //MARK: Returns the current location of device.
    func getUpdatedLocation() ->CLLocation{
        locationManager!.startUpdatingLocation()
        if(userLocation != nil){
            return userLocation
        }else{
            return CLLocation()
        }
    }
    //MARK: Starts Updating Location of user when needed
    func startUpdatingLocations(){
        
        locationManager!.startUpdatingLocation()
    }
    
    //MARK: Stops Updating Location when locations not needed from user
    func stopLocationUpdate() {
        locationManager!.stopUpdatingLocation()
    }
    
}
