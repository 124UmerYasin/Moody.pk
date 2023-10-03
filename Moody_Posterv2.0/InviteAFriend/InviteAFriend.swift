//
//  InviteAFriend.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 15/06/2021.
//

import Foundation
import UIKit
import Social
import Firebase

class InviteAFriend: UIViewController {

    
    @IBOutlet weak var InvitePageLabel: UILabel!
    
    var blackScreen: UIView!
    var MenuWidth: CGFloat!
    @IBOutlet weak var referCode: UITextField!
    
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var inviteButton: UIButton!
    static var invitefriendVisible: Bool = false
    
    
    //MARK: calls when first time View Loads
    //. referCide text is set to Invitecode field
    //. NavigationBar is set
    override func viewDidLoad() {
        super.viewDidLoad()

        referCode.text = String(UserDefaults.standard.integer(forKey: DefaultsKeys.inviteCode))
        referCode.isUserInteractionEnabled = false
        setupNavigationBar()
        navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Invite a Friend"
    }
    
    //MARK: Calls just before view appears
    //. Set Visibility and set inviteScreen bool
    //. checks profile icon badge in TabBar
    //. checks urdu language and changes in UI
    override func viewWillAppear(_ animated: Bool) {
        activityLoader.isHidden = true
        InviteAFriend.invitefriendVisible = true
        checkProfileIconBadge()
        checkAndStyleUrduLng()
    }
    
    //MARK: Calls when view disappers
    //. Reset inviteScreen Bool
    override func viewWillDisappear(_ animated: Bool) {
        InviteAFriend.invitefriendVisible = false
    }
    
    
    //MARK: copy codes from textFiled and save to clipboard
    @IBAction func copyCode(_ sender: Any) {
        UIPasteboard.general.string = referCode.text
        DispatchQueue.main.async {
            self.showToast(message: NSLocalizedString("Copied", comment: ""), font: .systemFont(ofSize: 17.0))
        }
    }
    

    //MARK: InviteAFirend button pressed
    //. Opens actionSheet
    @IBAction func inviteFriends(_ sender: Any) {
        inviteButton.isUserInteractionEnabled = false
        activityLoader.isHidden = false
        activityLoader.startAnimating()
        createLink()
    }
    
    //MARK: Styles labels on urdu lng check
    func checkAndStyleUrduLng(){
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: InvitePageLabel, text: InvitePageLabel.text ?? "Found Nothing in InvitePageLabel", lineSpacing: 6)
            InvitePageLabel.textAlignment = .right
            self.navigationItem.title = NSLocalizedString("Invite a Friend", comment: "")
        }
    }
    
    //MARK: Checks profile icon badge in TabBar
    func checkProfileIconBadge(){
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            tabBarController?.tabBar.items![3].image = UIImage(named:"notifiedSelectedProfile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
        }

    }
    //MARK: Setup navigation bar title
    func setNevTitleBtn()-> UIBarButtonItem{
        let homeTitle = UILabel()
        homeTitle.attributedText = NSAttributedString(string:  NSLocalizedString("Invite A Friend", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0)])
        return UIBarButtonItem(customView: homeTitle)
    }
}

/* MARK:- Extension Methods */
extension InviteAFriend{
    //MARK: It creates dynamic link which used to send for inviting a friend to MOODY
    func createLink(){
      var components = URLComponents()
        components.scheme = "https"
        components.host   = "www.moody.pk"
        components.path   = "/refer"
        let userReferCode = URLQueryItem(name: "referCode", value: referCode.text)
        components.queryItems = [userReferCode]
        
        guard let linkParameter = components.url else{
            inviteButton.isUserInteractionEnabled = true
            activityLoader.isHidden = true
            activityLoader.stopAnimating()
            return
        }
//        print("I am sharing \(linkParameter.absoluteString)")
        
        // create the big dynamic link
        let domain = "https://refer.moody.pk"
        guard let linkBuilder = DynamicLinkComponents
          .init(link: linkParameter, domainURIPrefix: domain) else {
            inviteButton.isUserInteractionEnabled = true
            activityLoader.isHidden = true
            activityLoader.stopAnimating()
            return
        }

        if let myBundleId = Bundle.main.bundleIdentifier{
            linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        linkBuilder.iOSParameters?.appStoreID = "1577145846"
        linkBuilder.iOSParameters?.minimumAppVersion = "1.0"
        linkBuilder.socialMetaTagParameters   = DynamicLinkSocialMetaTagParameters()
        linkBuilder.socialMetaTagParameters?.title = "Moody.pk"
        linkBuilder.socialMetaTagParameters?.descriptionText = "Hi, use my promo code in your Moody app to get free cash."
        linkBuilder.socialMetaTagParameters?.imageURL = URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple125/v4/1a/6b/ef/1a6beffa-61d8-134b-182b-32932a17153c/source/512x512bb.jpg")!
        linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.moody.poster")
        linkBuilder.androidParameters?.minimumVersion = 20
        


        
        guard let longUrl = linkBuilder.url else{
            inviteButton.isUserInteractionEnabled = true
            activityLoader.isHidden = true
            activityLoader.stopAnimating()
            return
        }
//        print("Long Url is \(longUrl.absoluteString)")
        
        linkBuilder.shorten{ [self](url, warnings, error) in
            if let error = error{
                print("Got an error \(error)")
                inviteButton.isUserInteractionEnabled = true
                activityLoader.isHidden = true
                self.activityLoader.stopAnimating()
                return
            }
            if let warnings = warnings{
                for warning in warnings{
                    print("Got warnings \(warning)")
                    inviteButton.isUserInteractionEnabled = true
                    activityLoader.isHidden = true
                    activityLoader.stopAnimating()
                }
            }
            guard let url = url else {
                inviteButton.isUserInteractionEnabled = true
                activityLoader.isHidden = true
                activityLoader.stopAnimating()
                return
                
            }
            print("Short link is \(url)")
            // sharing link
            let textToShare = [ url , "Hi, use my promo code in your Moody app to get free cash. \nCode : \(referCode.text ?? "")"] as [Any]
            let activityViewController = UIActivityViewController(
            activityItems: textToShare ,
            applicationActivities: nil
        )
        
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        // present the view controller
            DispatchQueue.main.async {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        inviteButton.isUserInteractionEnabled = true
        activityLoader.isHidden = true
        activityLoader.stopAnimating()
    }
}
