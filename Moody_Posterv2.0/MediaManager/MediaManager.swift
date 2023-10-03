//
//  MediaManager.swift
//  Moody_Posterv2.0
//
//  Created by   on 07/06/2021.
//

import Foundation
import UIKit
import AVFoundation

class MediaManager: UIViewController, UIImagePickerControllerDelegate{
    
    //MARK: TO PRESENT THE CAMERA
    static func presentCamera(parentController: UIViewController, isEditing: Bool){

        let imagePickerController =  UIImagePickerController()

        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            let auth = AVCaptureDevice.authorizationStatus(for: .video)
            switch auth {
            case .authorized, .notDetermined:
                imagePickerController.sourceType = .camera
                imagePickerController.delegate = (parentController as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
                imagePickerController.allowsEditing = isEditing
                parentController.present(imagePickerController, animated: true, completion: nil)
                break
        
            default:
                let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
            
                let alert = UIAlertController(
                    title: NSLocalizedString("Need Camera Access", comment: ""),
                    message: NSLocalizedString("Camera access is required to capture picture.", comment: ""),
                    preferredStyle: UIAlertController.Style.alert
                )
                alert.view.tintColor = UIColor(named: "ButtonColor")
                
               alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
               alert.addAction(UIAlertAction(title: NSLocalizedString("Allow Camera", comment: ""), style: .cancel, handler: { (alert) -> Void in
                   UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
               }))
           
                parentController.present(alert, animated: true, completion: nil)
            }
            
        }else{
            let alert = UIAlertController(title:  NSLocalizedString("Camera Unavailable.", comment: ""), message: NSLocalizedString("Camera not available or not working.", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
            parentController.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //MARK: TO PRESENT THE GALLEARY
    static func presentGalleary(parentController: UIViewController, isEditing: Bool){
        let imagePickerController =  UIImagePickerController()

        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = (parentController as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        imagePickerController.allowsEditing = isEditing
        parentController.present(imagePickerController, animated: true, completion: nil)
        

    }
}
