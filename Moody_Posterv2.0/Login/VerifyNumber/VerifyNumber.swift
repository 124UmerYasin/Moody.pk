//
//  VerifyNumber.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation
import UIKit
import youtube_ios_player_helper

class VerifyNumber : UIViewController , MyTextFieldDelegate{
    
    //MARK: TextFields Outlets
    @IBOutlet weak var textField1: MyTextField!
    @IBOutlet weak var textField2: MyTextField!
    @IBOutlet weak var textField3: MyTextField!
    @IBOutlet weak var textField4: MyTextField!
    
    //MARK: views Outlets
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    @IBOutlet weak var disableView: UIView!
    
    //MARK: Labels Outlets
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    
    //MARK: Buttons Outlets
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var getHelp: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var playerView: YTPlayerView!
    
    //MARK:  Variables
    var timer:Timer?
    var time:Int = Constants.RESEND_OTP_TIMER
    var invalidOTP = false
    static var deveiceToken:String?
    var fieldNumber:Int!
    var recivedCode: String!
    
    
    
    //MARK: calls when first time View Loads
    //. Ui styling
    //. Navigation bar styling
    //. StackView postioning
    override func viewDidLoad() {
        setupToHideKeyboardOnTapOnView()
        
        setupNavigationBar()
        setDelegate()
        setTextAlignment()
        stackView.contentMode = .left
        stackView.semanticContentAttribute = .forceLeftToRight

    }
    
    
    //MARK: underline code on getHelp Button 
        let underLine: [NSAttributedString.Key: Any] = [
              .font: UIFont.systemFont(ofSize: 20),
              .underlineStyle: NSUnderlineStyle.single.rawValue
          ]
        
    

    //MARK: Calls just before view appears
    //. Disables swipe gesture
    //. set OTP Timer
    //. OTP view is inistislised
    //. set helpStyling
    //. LocaliseHelpButton
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        configTimer()
        viewInitializion()
        setHelpStyling()
        LocaliseHelpButton()
       
    }
    //MARK: Sets Help button Styling
    func setHelpStyling(){
        let attributeString = NSMutableAttributedString(
            string: "GetHelp",attributes: underLine
                     )
        getHelp.setAttributedTitle(attributeString, for: .normal)

    }
    
    //MARK: Localise Help Button string
    func LocaliseHelpButton(){
        if UserDefaults.standard.string(forKey: "language") != "ur-Arab-PK"{
            getHelp.setAttributedTitle(NSAttributedString(string: "Get Help"), for: .normal)
        }else{
            getHelp.setAttributedTitle(NSAttributedString(string: "مدد حاصل کرو"), for: .normal)
        }
    }
    
    //MARK: TextField delegates register
    func setDelegate(){
        
        textField1.myDelegate = self
        textField2.myDelegate = self
        textField3.myDelegate = self
        textField4.myDelegate = self

        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self
    }
    
    
    //MARK: OTP Boxes views are inistailsed
    func viewInitializion(){
        textField1.becomeFirstResponder()
        hintLabel.text = RegisterNumber.number!
        
        inilizesUIViews(view1)
        inilizesUIViews(view2)
        inilizesUIViews(view3)
        inilizesUIViews(view4)
    }
    
    //MARK: resend Otp
    //. Register Number api calls again in resendOTP method
    @IBAction func resendBtnTap(_ sender: Any) {
        resendOPT()
    }
 

    //MARK: Generic method which sets OTP box view and its view styling is set
    func inilizesUIViews(_ view: UIView){
        view.layer.borderWidth = 1.4
        view.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        view.layer.cornerRadius = 3
    }
    
    //MARK: OTP box view border color are set
    func setViewBoader(_ color: UIColor){
        view1.layer.borderColor = color.cgColor
        view2.layer.borderColor = color.cgColor
        view3.layer.borderColor = color.cgColor
        view4.layer.borderColor = color.cgColor
    }
    
    
//MARK: On HelpButton it open whatsapp app for any help needed from moody
    @IBAction func onclickWhatsapp(_ sender: Any) {
        let urlWhats = "whatsapp://send?phone=+923236169577&text=Hello"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(whatsappURL)
                    }
                }
                else {
                    presentAlert(title: NSLocalizedString("Customer Support", comment: ""), message: NSLocalizedString("Please Downlaod whatsapp in your device", comment: ""), parentController: self)
                    print("Install Whatsapp")
                }
            }
        }
    }
}

