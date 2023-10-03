//
//  SettingsVC.swift
//  Moody_Posterv2.0
//
//  Created by   on 13/07/2021.
//

import Foundation
import UIKit
import StoreKit


class SettingsVC: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var arrow1: UIImageView!
    @IBOutlet weak var arrow2: UIImageView!
    @IBOutlet weak var arrow3: UIImageView!
    
    
    //MARK: Variables
    var checkDirection : Bool = true
    static var SettingVisible = false
    
    //MARK: calls when first time View Loads
    //. Set NavigationBar
    //. Set User Data
    //. Set Target to Profile Image
    override func viewDidLoad() {
        setupNavigationBar()
        setData()
        activityLoader.isHidden = true
        viewInilization()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onImageClick))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tap)
       
    }
    //MARK: Sets user data
    override func viewDidAppear(_ animated: Bool) {
        setData()
    }
    
    //MARK: Reset bool
    override func viewWillDisappear(_ animated: Bool) {
        SettingsVC.SettingVisible = false
    }
    
    //MARK: Calls just before view appears
    //. bool set
    //. profile badge icon check
    //. setting ui for urdu
    override func viewWillAppear(_ animated: Bool) {
                
        SettingsVC.SettingVisible = true
        checkProfileIconBadge()
        setUrduUi()
    }
    
    
    func setUrduUi(){
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            if checkDirection == true{
                arrow1.transform = arrow1.transform.rotated(by: .pi)
                arrow2.transform = arrow2.transform.rotated(by: .pi)
                arrow3.transform = arrow3.transform.rotated(by: .pi)
                checkDirection = false
            }
           
            
        }
    }
    
    //MARK: Checks profile icon image of TabBar
    func checkProfileIconBadge(){
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            tabBarController?.tabBar.items![3].image = UIImage(named:"notifiedSelectedProfile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
        }
    }
        
    //MARK: Sets Back Button image and color
    func viewInilization(){
        
        let image = UIImage(named: "blackBackButton")!.withRenderingMode(.alwaysTemplate)
        
        backBtn.setImage(image, for: .normal)
        backBtn.tintColor = UIColor(named: "DarkGray")
    }
    
    //MARK: Sets User Data saved in userDefaults
    //. userName, rating, profileImage are set here
    func setData(){
        if(UserDefaults.standard.string(forKey: DefaultsKeys.name) != nil){
            usernameLabel.text = UserDefaults.standard.string(forKey: DefaultsKeys.name)
        }
        if(UserDefaults.standard.double(forKey: DefaultsKeys.poster_rating) != 0){
            ratingLabel.attributedText = NSMutableAttributedString().starWithRating(rating: Float(Int(UserDefaults.standard.double(forKey: DefaultsKeys.poster_rating))) , outOfTotal: 5, withFontSize: 70)
            ratingLabel.attributedText = NSMutableAttributedString().starWithRating(rating: Float(Int(UserDefaults.standard.double(forKey: DefaultsKeys.poster_rating))) , outOfTotal: 5, withFontSize: 70)
        }else{
            ratingLabel.attributedText = NSMutableAttributedString().starWithRating(rating: 0, outOfTotal: 5, withFontSize: 70)
        }
        
        if(UserDefaults.standard.data(forKey: DefaultsKeys.profile_picture) != nil){
            profileImage.image = UIImage(data: Data(UserDefaults.standard.data(forKey: DefaultsKeys.profile_picture)!))
            
        }else{
            profileImage.image = UIImage(named: "person2")
        }
    }
    
    //MARK: Navigates to PersonalInfo
    @IBAction func personalDidTap(_ sender: Any) {
        navigateToNextScreen("Settings", "PresonalInfoVC")
    }
    
    //MARK: Navigates to Language Screen
    @IBAction func languageDidTap(_ sender: Any) {
        navigateToNextScreen("Settings", "LanguageVC")
    }
    
    //MARK: Navigates to App store to rate
    @IBAction func rateDidTap(_ sender: Any) {
        rateApp()
    }
    
    //MARK: Edit users profile image
    //. Actionsheet opens to remove, edit or open camera 
    @IBAction func editImageDidTap(_ sender: Any) {
        presentAlert()
    }
    

    
    
    //MARK: pops back to ProfileScreen
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Opens app store to rate app
    func rateApp() {
        
        let appID = (String(describing: Bundle.main.infoDictionary?["CFBundleIdentifier"]))
        let url = URL(string: "itms-apps://itunes.apple.com/app/1577145846")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    @objc func onImageClick(){
        presentAlert()
    }
}


extension SettingsVC: UINavigationControllerDelegate{
    
    //MARK: Opens Actionsheet to edit/remove users profile image
    func presentAlert(){
        
        let profileEditOptions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        profileEditOptions.view.tintColor = UIColor(named: "ButtonColor")
        
        profileEditOptions.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default, handler: { [self] (action) in
            MediaManager.presentCamera(parentController: self, isEditing: true)

        }))
        profileEditOptions.addAction(UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default, handler: { [self] (action) in
            MediaManager.presentGalleary(parentController: self, isEditing: true)
        }))
        
        if !(UserDefaults.standard.data(forKey: DefaultsKeys.profile_picture) == UIImage(named: "person2")!.pngData()){
            
            profileEditOptions.addAction(UIAlertAction(title: NSLocalizedString("Remove Image", comment: ""), style: .default, handler: { (action) in
                self.removeImage()
                
            }))
        }
  
        
        profileEditOptions.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
            
        }))
        
        profileEditOptions.popoverPresentationController?.sourceView = self.view
        profileEditOptions.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.maxX/2 ,y: self.view.frame.maxY ,width: 0 ,height: 0);
        profileEditOptions.popoverPresentationController?.permittedArrowDirections = []
        
        self.present(profileEditOptions, animated: true, completion: nil)
    }
    
    
    //MARK: Removes profile imgae
    func removeImage(){
        var dictionary = [String:Any]()
      
        dictionary["profile_picture"] = "null"
        dictionary["extension"] = "jpg"
        UserDefaults.standard.set(UIImage(named: "person2")!.pngData(), forKey: DefaultsKeys.profile_picture)
        profilePictureAPICall(dictionary:  dictionary)

    }
    //MARK: Update User Api call
    //. OnSuccess Updates profile picture and userdefaults values
    func profilePictureAPICall(dictionary:  [String:Any]){
        if(CheckInternet.Connection()){
            startLoader()
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.updateUser, dictionary: dictionary, httpMethod: Constants.httpMethod, token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (result) in
                switch result {
                case .success(_):
                    updateProfilePicture()
                    break
                case .failure(let error):
                    DispatchQueue.main.async {
                        presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(error.title, comment: ""), parentController: self)
                        stopLoader()
                    }
                    break
                }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)
        }
    }
    
    //MARK: Sets new profile image
    //. ui changes and update userdefault value
    func updateProfilePicture(){
       
        DispatchQueue.main.async { [self] in
            profileImage.image = UIImage(data: Data(UserDefaults.standard.data(forKey: DefaultsKeys.profile_picture)!))
            profileImage.contentMode = .scaleToFill
            stopLoader()
            UserDefaults.standard.set(UserDefaults.standard.data(forKey: DefaultsKeys.profile_picture)!, forKey: DefaultsKeys.profile_picture)

        }
        
    }
    
    //MARK: Starts activity loader
    func startLoader(){
        view.isUserInteractionEnabled = false
        activityLoader.startAnimating()
        activityLoader.isHidden = false
    }
    //MARK: Stops activity loader
    func stopLoader(){
        view.isUserInteractionEnabled = true
        activityLoader.stopAnimating()
        activityLoader.isHidden = true
    }
    
    
}

