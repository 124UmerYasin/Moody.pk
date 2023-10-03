//
//  Permissions.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 04/06/2021.
//

import Foundation
import AVKit


extension TaskCreationViewController{
    

    //MARK: check audio permission.
    func checkMicrophoneAccess(completion: @escaping (Bool) -> Void){
        DispatchQueue.main.async { [self] in
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.granted:
                completion(true)
            case AVAudioSession.RecordPermission.denied:
                settingsCustomAlert(title: "Audio Permission")
                
                completion(false)
            case AVAudioSession.RecordPermission.undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                    if(granted){
                        DispatchQueue.main.async {
                            completion(true)
                        }
                    }else{
                        completion(false)
                    }
                })
            @unknown default:
                print("Faliled To Get Record Audio Permission")
            }
        }
    }
    
    
    //MARK: generic custom alert .
    func settingsCustomAlert(title: String){
        DispatchQueue.main.async {
            let alert  = UIAlertController(title: title, message: "Please Allow " + title + " From Settings", preferredStyle: .alert)
            alert.view.tintColor = UIColor(named: "ButtonColor")
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)! as URL)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
