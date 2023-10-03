//
//  CallPermissions.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 09/06/2021.
//

import Foundation
import QuickbloxWebRTC

struct CallErrorConstant {
    static let cameraErrorTitle = NSLocalizedString("Camera error", comment: "")
    static let cameraErrorMessage = NSLocalizedString("The app doesn't have access to the camera, please go to settings and enable it.", comment: "")
    static let microphoneErrorTitle = NSLocalizedString("Microphone error", comment: "")
    static let microphoneErrorMessage = NSLocalizedString("The app doesn't have access to the microphone, please go to settings and enable it.", comment: "")
    static let alertCancelAction = NSLocalizedString("Cancel", comment: "")
    static let alertSettingsAction = NSLocalizedString("Settings", comment: "")
}

class CallPermissions {
    //MARK: - Class Methods
    class func check(with conferenceType: QBRTCConferenceType, completion: @escaping (_ granted: Bool) -> Void ) {
        
        #if targetEnvironment(simulator)
        completion(true)
        return
        #endif
        
        self.requestPermissionToMicrophone(withCompletion: { granted in
            guard granted == true else {
                showAlert(withTitle: CallErrorConstant.microphoneErrorTitle,
                          message: CallErrorConstant.microphoneErrorMessage)
                completion(granted)
                return
            }
            switch conferenceType {
            case .audio:
                completion(granted)
            case .video:
                requestPermissionToCamera(withCompletion: { videoGranted in
                    if videoGranted == false {
                        showAlert(withTitle: CallErrorConstant.cameraErrorTitle,
                                  message: CallErrorConstant.cameraErrorMessage)
                    }
                    completion(videoGranted)
                })
            @unknown default:
                fatalError()
            }
        })
    }
    
    class func requestPermissionToMicrophone(withCompletion completion: @escaping (_ granted: Bool) -> Void ) {
        AVAudioSession.sharedInstance().requestRecordPermission({ granted in
            DispatchQueue.main.async(execute: {
                completion(granted)
            })
        })
    }
    
    class func requestPermissionToCamera(withCompletion completion: @escaping (_ granted: Bool) -> Void ) {
        let mediaType = AVMediaType.video
        let authStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { granted in
                DispatchQueue.main.async(execute: {
                    completion(granted)
                })
            })
        case .restricted, .denied:
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            fatalError()
        }
    }
    
    // MARK: - Helpers
    // showing error alert with a suggestion
    // to go to the settings
    class func showAlert(withTitle title: String?, message: String?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: CallErrorConstant.alertCancelAction,
                                                style: .cancel))
        alertController.addAction(UIAlertAction(title: CallErrorConstant.alertSettingsAction,
                                                style: .default,
                                                handler: { action in
                                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                                        UIApplication.shared.open(url, options: [:])
                                                    }
        }))
        alertController.view.tintColor = UIColor(named: "ButtonColor")
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
    }
}
