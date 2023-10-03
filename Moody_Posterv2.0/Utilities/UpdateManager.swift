//
//  UpdateManager.swift
//  Moody_TaskerV2.0
//
//  Created  by Umer Yasin on 04/08/2021.
//

import Foundation
import UIKit


class CheckUpdate: NSObject {

    static let shared = CheckUpdate()
    var currentAppstoreVersion = ""

    //MARK: Recieves bool and check current version of app
    func showUpdate(withConfirmation: Bool) {
            self.checkVersion(force : !withConfirmation)
    }
  

    //MARK: Checks version of App
    private  func checkVersion(force: Bool) {
        getCurrentVersionOfApp()
    }

    //MARK: Using for checking Update of App published on App store. Showing Update Alert
    func getCurrentVersionOfApp(){
        guard let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else { return }
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else { return }
       
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data)
                    guard let json = jsonObject as? [String: Any] else {
                        print("The received that is not a Dictionary")
                        return
                    }
                    let results = json["results"] as? [[String: Any]]
                    let firstResult = results?.first
                    self.currentAppstoreVersion = firstResult?["version"] as? String ?? "1.3"
                    let trackViewURl = firstResult?["trackViewUrl"] as? String ?? "https://apps.apple.com/us/app/moody-fulfilling-your-needs/id1577145846?uo=4"
                    print("currentVersion: ", self.currentAppstoreVersion)
                    if let currentVersion = self.getBundle(key: "CFBundleShortVersionString") {
                    if  currentVersion < self.currentAppstoreVersion  {
                        print("Needs update: AppStore Version: \(self.currentAppstoreVersion) > Current version: ",currentVersion)
                        DispatchQueue.main.async {
                            let topController: UIViewController = (UIApplication.shared.windows.first?.rootViewController)!
                            topController.showAppUpdateAlert(Version: currentVersion, Force: true, AppURL: trackViewURl)
                        }
                     }
                   }
                }
          catch let serializationError {
                    print("Serialization Error: ", serializationError)
                }
            } else if let error = error {
                print("Error: ", error)
            } else if let response = response {
                print("Response: ", response)
            } else {
                print("Unknown error")
            }
        }
        task.resume()
         
    }
    
    //MARK: - Retruns value of plist objects
    func getBundle(key: String) -> String? {

        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
          fatalError("Couldn't find file 'Info.plist'.")
        }
        // 2 - Add the file to a dictionary
        let plist = NSDictionary(contentsOfFile: filePath)
        // Check if the variable on plist exists
        guard let value = plist?.object(forKey: key) as? String else {
          fatalError("Couldn't find key '\(key)' in 'Info.plist'.")
        }
        return value
    }
}

extension UIViewController {
    
    //MARK: Shows app update dialog
    @objc fileprivate func showAppUpdateAlert( Version : String, Force: Bool, AppURL: String) {


        let alert = AlertService().presentUpdateAlert{
            
            guard let url = URL(string: AppURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }

        }


        present(alert, animated: true, completion: nil)
        
        

        _ = UIAlertAction(title: "Update", style: .default) { (action:UIAlertAction) in
            guard let url = URL(string: AppURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }

    }
}
