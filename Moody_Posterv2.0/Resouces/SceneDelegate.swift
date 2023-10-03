//
//  SceneDelegate.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import UIKit
import CoreData
import GoogleMaps
import Firebase
import Network
import FirebaseMessaging
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD
//import FacebookCore

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
//        ApplicationDelegate.shared.application(
//            UIApplication.shared,
//            open: url,
//            sourceApplication: nil,
//            annotation: [UIApplication.OpenURLOptionsKey.annotation]
//        )
        
    }
    
    //MARK: Dynamic link handling for invite a friend
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("I have recieved a url through custom scheme \(url.absoluteString)")

        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
            self.handleIncomingDynamicLink(dynamicLink)
            
            let dict = ["func name" : "open url",
                "dynamicLink": "\(dynamicLink)" ] as [String : Any]

            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            return true
        }
        else{
            let dict = ["func name" : "open url",
                "dynamicLink": "not found"] as [String : Any]

            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            return false
        }
    }
    
    //MARK: Dynamic loink handling for ios version above 13
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        // the url is going to be in userActivity.webpageURL
        if let incomingURL = userActivity.webpageURL{
            
            print("Incoming URL link is \(incomingURL)")
            
            let dict = ["func name" : "continue userActivity",
                "Incoming URL link is": "\(incomingURL)" ] as [String : Any]

            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)

            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamiclink, error) in
                guard error == nil else{
                    print("Error is \(String(describing: error?.localizedDescription))")
                    let dict = ["func name" : "continue userActivity",
                        "Error is ": "\(String(describing: error?.localizedDescription))" ] as [String : Any]

                    whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
                    return
                }
                if let dynamicLink = dynamiclink{
                    self.handleIncomingDynamicLink(dynamiclink!)
                    print("Error is \(String(describing: error?.localizedDescription))")
                    let dict = ["func name" : "continue userActivity",
                                "dynamicLink": "\(String(describing: dynamiclink))" ] as [String : Any]

                    whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
                }
            }
        }

    }
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink){

        guard let url = dynamicLink.url else{
            
            let dict = ["func name" : "handleIncomingDynamicLink",
                        "url": "\(String(describing: dynamicLink.url))" ] as [String : Any]

            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            print("No dynamicLink URL")
            
            return
        }
        
        let dict = ["func name" : "handleIncomingDynamicLink",
            "url": "\(dynamicLink.url)" ] as [String : Any]

        whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
        
        print("Your Incoming link parameters are \(url.absoluteString)")
        guard (dynamicLink.matchType == .unique || dynamicLink.matchType == .default)
        else{
            print("Not a strong matchType to continue")
            return
        }
        //parse the link parameter
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems =  components.queryItems else{return}
        if components.path == "/refer"{
            let dict = ["func name" : "handleIncomingDynamicLink",
                "components.path": "\(components.path)" ] as [String : Any]

            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
            if let referCodeItem = queryItems.first(where: {$0.name == "referCode"}){
                guard let refCode = referCodeItem.value else{return}
                UserDefaults.standard.setValue(refCode, forKey: "refCode")
                var dictionary = [String:Any]()
                if refCode != ""{
                    print(UserDefaults.standard.string(forKey: "refCode")!)
                    dictionary["invite_code"] = refCode
                    validatePromoCode(dictionary: dictionary)
                }
            }
        }else {
            let dict = ["func name" : "handleIncomingDynamicLink",
                "components.path": "nil" ] as [String : Any]

            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
        }
    }
    
    //MARK: Send promo code ios version for above 13
        func validatePromoCode(dictionary : [String:Any]){
            let dict = ["func name" : "validatePromoCode Called"] as [String : Any]

            whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)

            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.validateInviteCode, dictionary: dictionary, httpMethod: Constants.httpMethod, token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (result) in

                switch result {
                case .success(let response):
                    let dict = ["func name" : "validatePromoCode Called",
                        " success response": "\(response)"] as [String : Any]

                    whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)

                    print("Successs")
                case .failure(let error):
                    
                    let dict = ["func name" : "validatePromoCode Called",
                                " error response": "\(error.localizedDescription)"] as [String : Any]

                    whistleWebhook.sharedInstance.errorLogsToWhistle(sendBodyData: dict)
                    print("Failure")
                    break
                }
            }
        }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        //UNUserNotificationCenter.current().removeAllDeliveredNotifications()

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

