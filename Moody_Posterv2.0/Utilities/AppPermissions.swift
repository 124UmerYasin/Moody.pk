//
//  AppPermissions.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 14/06/2021.
//

import Foundation
import CoreLocation
import AVKit
import YPImagePicker

//MARK: Checks Application Permission
public class AppPermission{
    
    //MARK: check location permission
    class func isLocationAccessEnabled() ->Bool{
        var permissionBool:Bool = false
       if CLLocationManager.locationServicesEnabled() {
          switch CLLocationManager.authorizationStatus() {
             case .notDetermined, .restricted, .denied:
                permissionBool = false
             case .authorizedAlways, .authorizedWhenInUse:
                permissionBool = true
          @unknown default:
            //print"Faliled To Get Location Permission")
            permissionBool = false
          }
       } else {
          //print"Location services not enabled")
        permissionBool = false
       }
        return permissionBool
    }
    
    //MARK: check audio permission
    class func audiopermission() -> Bool{
        var permissionBool:Bool = false
        switch AVAudioSession.sharedInstance().recordPermission{
        case .undetermined:
            permissionBool = false
        case .denied:
            permissionBool = false
        case .granted:
            permissionBool = false
        @unknown default:
            permissionBool = false
        }
        return permissionBool
    }
    
    //MARK: check camera permission
    class func cameraPermission()-> Bool{
        var permissionBool:Bool = false
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAuthorizationStatus{
        case .notDetermined:
            permissionBool = false
        case .restricted:
            permissionBool = false
        case .denied:
            permissionBool = false
        case .authorized:
            permissionBool = false
        @unknown default:
            permissionBool = false
        }
        return permissionBool
    }
    
    //MARK: Return all DeviceInformation 
    class func getDeviceInfo() -> String{
        let udid = UIDevice.current.identifierForVendor?.uuidString
        let name = UIDevice.current.name
        let version = UIDevice.current.systemVersion
        let modelName = UIDevice.current.model
        
        let userAgent = "\(udid ?? "")  \(name)   \(version)    \(modelName)"
        return userAgent
        
    }
}
