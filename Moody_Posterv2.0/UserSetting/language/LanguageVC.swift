//
//  LanguageVC.swift
//  Moody_Posterv2.0
//
//  Created by   on 13/07/2021.
//

import Foundation
import UIKit

class LanguageVC: UIViewController{
    
    
    //MARK: Outlets
    @IBOutlet weak var engBoolImg: UIImageView!
    @IBOutlet weak var urduBoolImg: UIImageView!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var selectLanguageLabel: UILabel!
    
    //MARK: Variables
    var selectedLang: String!
    static var languageVisible = false
    

    
    //MARK: calls when first time View Loads
    //. intialise Views of Screen
    //. set radio btn to selcted lng
    override func viewDidLoad() {
        activityLoader.isHidden = true
        disableBtn(updateBtn)
        viewInilization()
        setRadioBtn()
    }
    
    //MARK: Calls just before view appears
    //. bool set
    //. profile badge icon check
    //. setting ui for urdu
    override func viewWillAppear(_ animated: Bool) {
        LanguageVC.languageVisible = true
        checkProfileIconBadge()
        setUrduUi()

    }
    
    //MARK: calls when view disappears
    //. reset bool
    override func viewWillDisappear(_ animated: Bool) {
        LanguageVC.languageVisible = false
    }
    
    
    //MARK: Set ui for Urdu
    func setUrduUi(){
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: selectLanguageLabel, text: selectLanguageLabel.text ?? "Found Nothing in selectLanguageLabel", lineSpacing: 8)
            selectLanguageLabel.textAlignment = .right
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
    
    //MARK: selects english lng
    @IBAction func isEnglishTap(_ sender: Any) {
        selectedLang = "Base"
        selectLanguage(selectedLang: "eng")
        
    }
    
    //MARK: selects urdu lng
    @IBAction func isUrduTap(_ sender: Any) {
        selectedLang = "ur-Arab-PK"
        selectLanguage(selectedLang: "urdu")
    }
    
    //MARK: selected languages box checked
    func selectLanguage(selectedLang: String){
        engBoolImg.image = UIImage(named: "radioUncheck")
        urduBoolImg.image = UIImage(named: "radioUncheck")
        switch selectedLang {
        case "eng":
            engBoolImg.image = UIImage(named: "radioCheck")
        case "urdu":
            urduBoolImg.image = UIImage(named: "radioCheck")
        default:
            break
        }
        enableBtn(updateBtn)
    }
    
    //MARK: pops back to UserSettings
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Update Lng Api call
    //. selected lng are fetched and sent in api
    @IBAction func updateDidTap(_ sender: Any) {
        if UserDefaults.standard.string(forKey: "language") != selectedLang{
            if  selectedLang == "Base" {
                updateLanguageAPICall("en")
            }else{
                updateLanguageAPICall( "urdu" )
            }
        }
    }
    
    //MARK: Sets back btn image and color
    func viewInilization(){
        let image = UIImage(named: "blackBackButton")!.withRenderingMode(.alwaysTemplate)
        backBtn.setImage(image, for: .normal)
        backBtn.tintColor = UIColor(named: "DarkGray")
    }
    
    //MARK: Sets selected Radio button
    func setRadioBtn(){
        
        if UserDefaults.standard.string(forKey: "language") == "Base"{
            selectLanguage(selectedLang: "eng")
        }else{
            selectLanguage(selectedLang: "urdu")
        }
        selectedLang = UserDefaults.standard.string(forKey: "language")
    }
    
    //MARK: Update Lng Api calls
    //. dict is prepared for updateLng api
    //. onSuccess Ui changes updates
    func updateLanguageAPICall(_ lang: String){
        if(CheckInternet.Connection() ){
            upadteLoader(isAnimating: true)
            var dictionary = [String:Any]()
            dictionary["lang"] = lang
            dictionary["user_agent"] = AppPermission.getDeviceInfo()
            dictionary["platform"] = "iOS"
        
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.updateUser, dictionary: dictionary, httpMethod: Constants.httpMethod, token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (result) in
                
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        Bundle.setLanguage(selectedLang)
                        UserDefaults.standard.setValue(selectedLang, forKey: "language")
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                         UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateInitialViewController()
                        upadteLoader(isAnimating: false)
                    }
                    break
                case .failure(let error):
                    DispatchQueue.main.async {
                        upadteLoader(isAnimating: false)
                        presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(error.title, comment: ""), parentController: self)
                    }
                    break
                }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please try again later when internet is available", comment: ""), parentController: self)
        }
        
    }
    
    //MARK: Generic method to stop/play loader
    func upadteLoader(isAnimating: Bool){
        if isAnimating{
            self.view.isUserInteractionEnabled = false
            activityLoader.isHidden = false
            activityLoader.startAnimating()
            disableBtn(updateBtn)
        }else{
            self.view.isUserInteractionEnabled = true
            activityLoader.isHidden = true
            activityLoader.stopAnimating()
            enableBtn(updateBtn)
        }
    }
    
}
