//
//  PresonalInfoVC.swift
//  Moody_Posterv2.0
//
//  Created by   on 13/07/2021.
//

import Foundation
import UIKit


class PresonalInfoVC: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var personalInfoLabel: UILabel!
    
    //MARK: Variables
    var emailEditBool: Bool = false
    var usernameEditBool: Bool = false
    var isValidToCallAPI:Bool = false
    static var profileInfoVisible = false
    

    //MARK: calls when first time View Loads
    //. TapGesture to add hideKeyboard
    //. intialise Views of PersonalInfo Screen
    //. Sets users data to respective fields
    //. TextFiled delegates are set
    override func viewDidLoad() {
        
        setupToHideKeyboardOnTapOnView()
        inlizeViews()
        setData()
        setDelegate()
        
    }
    
    //MARK: Calls just before view appears
    //. bool set
    //. profile badge icon check
    //. setting ui for urdu
    override func viewWillAppear(_ animated: Bool) {
        
        PresonalInfoVC.profileInfoVisible = true
        checkProfileIconBadge()
        setUrduUi()
        
    }
    
    //MARK: Resets bool 
    override func viewWillDisappear(_ animated: Bool) {
        PresonalInfoVC.profileInfoVisible = false
    }
    
    //MARK: TextField Delegates register
    func setDelegate(){
        usernameTF.delegate = self
        emailTF.delegate = self
    }
    
    //MARK: Set ui for Urdu
    func setUrduUi(){
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: personalInfoLabel, text: personalInfoLabel.text ?? "Found Nothing in labelDepositDescription", lineSpacing: 4)
            personalInfoLabel.textAlignment = .right
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

    
    //MARK: Sets Data to textFields saved in UserDefaults from constants
    func setData(){
        
        let number = UserDefaults.standard.string(forKey: DefaultsKeys.phone_number) ?? " "

        usernameTF.attributedPlaceholder = NSAttributedString(string: "Enter your name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        phoneTF.attributedPlaceholder = NSAttributedString(string: number, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        emailTF.attributedPlaceholder = NSAttributedString(string: "Enter your email" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        let userName = UserDefaults.standard.value(forKey: DefaultsKeys.name) as? String
        let userEmail = UserDefaults.standard.value(forKey: DefaultsKeys.email) as? String

        if  userName != "" {
            usernameTF.text = userName
        }
        if userEmail != "" {
            emailTF.text = userEmail
        }
    
    }
    
    //MARK: Intialise views of Screen
    func inlizeViews(){
        setviewBoader(usernameView)
        setviewBoader(phoneView)
        setviewBoader(emailView)
        disableBtn(updateBtn)
        phoneTF.isUserInteractionEnabled = false
        activityLoader.isHidden = true
        viewInilization()
        
        usernameTF.textAlignment = .left
        phoneTF.textAlignment = .left
        emailTF.textAlignment = .left
    }
    
    //MARK: Generic function to style views
    func setviewBoader(_ view: UIView){
        
        view.layer.borderWidth = 1.3
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 3
        view.layer.borderColor = UIColor(named: "AppTextColor")?.cgColor
        
    }
    
    
    //MARK: Back Button image and color
    func viewInilization(){
        
        let image = UIImage(named: "blackBackButton")!.withRenderingMode(.alwaysTemplate)
        backBtn.setImage(image, for: .normal)
        backBtn.tintColor = UIColor(named: "DarkGray")
    }
    
        
    //MARK: userUpdate Api call
    @IBAction func updateDidTap(_ sender: Any) {
        userUpadteAPICall()
        disableBtn(updateBtn)
    }
    
    //MARK: Pops back to setting screen
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Updates userName
    func updateUserName(){
        if isVaildName(usernameTF.text ?? ""){
            isValidToCallAPI = true
        }else{
            presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Enter Vaild Username", comment: ""), parentController: self)
        }
        
    }
    
    //MARK: Updates Email
    func updateEmail(){
        if isVaildEmail(emailTF.text ?? ""){
            isValidToCallAPI = true
        }else{
            presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Enter Vaild Email", comment: ""), parentController: self)
        }
    }
}


extension PresonalInfoVC: UITextFieldDelegate{
    
    //MARK: Dectects when editing begins in the text field.
    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == usernameTF {
            usernameEditBool = true
        }
        if textField == emailTF {
            emailEditBool = true
        }
    }
    //MARK: Dectects when editing ends in the text field.
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if usernameEditBool && usernameTF.text?.count == 0{
            usernameEditBool = false
        }
        
        if emailEditBool && emailTF.text?.count == 0{
            emailEditBool = false
        }
        
        if usernameEditBool || emailEditBool{
            enableBtn(updateBtn)
        }
    }
}


extension PresonalInfoVC{
    
    //MARK: setting up dicitianory for API Call
    func setDictionary()-> [String:Any]{
        
        var dictionary = [String:Any]()
        if(usernameEditBool){
            dictionary["name"] = usernameTF.text!
        }
        if(emailEditBool){
            dictionary["email"] = emailTF.text!
        }
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "iOS"
        
        return dictionary
    }
    
    //MARK: API Call to update user information
    //. OnSuccess userinformation is updated in local userDefaults
    func userUpadteAPICall(){
        if(CheckInternet.Connection()){
            activityLoader.isHidden = false
            activityLoader.startAnimating()
            
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.updateUser, dictionary: setDictionary(), httpMethod: Constants.httpMethod, token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (result) in
                
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        updateUserDefault()
                        presentAlert(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Profile updated successfully", comment: ""), parentController: self)
                        stopLoader()
                    }
                    break
                case .failure(let error):
                    DispatchQueue.main.async {
                        //changeBtnsInteractions(enableInteraction: true)
                        presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(error.title, comment: ""), parentController: self)
                        stopLoader()
                        
                    }
                    break
                }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please try again later when internet is available", comment: ""), parentController: self)
        }
        
    }
    

    //MARK: -Updates userDefaults if username/email updates
    func updateUserDefault(){
        if usernameEditBool{
            UserDefaults.standard.set(usernameTF.text!  as String ,forKey: DefaultsKeys.name)
        }
        if emailEditBool{
            UserDefaults.standard.set(emailTF.text!  as String ,forKey: DefaultsKeys.email)
        }
    }
    
    //MARK: Stops Loader
    func stopLoader(){
        emailEditBool = false
        usernameEditBool = false
        activityLoader.stopAnimating()
        activityLoader.isHidden = true
    }

}
