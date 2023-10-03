//
//  ConfirmPaymentViewController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 05/06/2021.
//

import Foundation
import UIKit
import IHKeyboardAvoiding

class ConfirmPaymentViewController: UIViewController, UITextFieldDelegate{
    
    //MARK: Outlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var screenText: UILabel!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var transactionId: UITextField!
    @IBOutlet weak var detailLable: UILabel!
    @IBOutlet weak var buttonUpText: UILabel!
    @IBOutlet weak var activityLoader:
        UIActivityIndicatorView!
    @IBOutlet weak var transactionLabel: UILabel!
    
    //MARK: Variables
    var methodType: String = ""
    var image: UIImage!
    var screenTextLabel: String = ""
    var topupAmount: Int = 0
    
    var dictionary = [String:Any]()
    
    let currentUser = sender(senderId: "Self", displayName: NSLocalizedString("Me", comment: ""))
    let deo = sender(senderId: "deo", displayName:  NSLocalizedString("Customer Support", comment: ""))
    
    //MARK: calls when first time View Loads
    //. views and constraints are set
    //. moody MobileNumber is set
    //. tapGesture on keypad hide
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KeyboardAvoiding.avoidingView = self.view
        activityLoader.isHidden = true
        setupNavigationBar()
        setConstraints()
        mobileNumber.text = UserDefaults.standard.string(forKey: DefaultsKeys.moody_phone_number)
        setupToHideKeyboardOnTapOnView()
        setLogoImage()
        setViews()
        setButtonConstraints()
        textFieldLeftPadding(textFieldName: mobileNumber)
        textFieldLeftPadding(textFieldName: transactionId)
    }
    
    //MARK: Calls just before view appears
    //. Set styling if urdu lng is set
    //. NavigationBar hidden
    //. transactionId placeholder is set and localised
    override func viewWillAppear(_ animated: Bool) {

        setUrduStyling()
        navigationController?.isNavigationBarHidden = true
        transactionId.placeholder = NSLocalizedString("Transaction ID", comment: "")
    }
    
    
    //MARK: Checks if urdu lng is select
    //. Styles text fields
    func setUrduStyling(){
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: screenText, text: screenText.text ?? "Found Nothing in screenText", lineSpacing: 15)
            screenText.textAlignment = .center
            transactionId.attributedPlaceholder =  NSAttributedString(string: "Transaction ID", attributes: [.font: UIFont.systemFont(ofSize: 12) ])
        }
    }
    //MARK: MobileNumber constraints are set
    func setConstraints(){
        mobileNumber.translatesAutoresizingMaskIntoConstraints = false
        mobileNumber.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: (self.view.frame.width) * 0.8 ).isActive = true
    }
    
    
    //MARK: Textfield delegate calls when there is change in text
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var textCount: Int = textField.text!.count
        if(string == ""){
            textCount -= 1
        }
        else{
            textCount += 1
        }
        
        return fieldsHandling(string: string , textField: textField, textCount: textCount)
        
        
    }
    
    //MARK: Text field handling
    func fieldsHandling(string: String, textField: UITextField, textCount: Int) -> Bool{
        
        if textCount >= UserDefaults.standard.string(forKey: DefaultsKeys.minimum_amount_for_top_up)!.count && textCount <= UserDefaults.standard.string(forKey: DefaultsKeys.maximum_top_up_amount)!.count {
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(named: "AccentColor")
        }else{
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(named: "DullGreen")
        }
        return true
    }
    
    
    //MARK: Preparing topUp task dict
    func createTopupTaskDictionary() -> [String:Any]{
        let loc = LocationManagers.locationSharesInstance.getUpdatedLocation()
        var dictData = [String:Any]()
        dictData["poster_location"] = "\(loc.coordinate.latitude), \( loc.coordinate.longitude)"
        dictData["type"] = "top_up"
        dictData["user_agent"] = AppPermission.getDeviceInfo()
        dictData["platform"] = "ios"
        
        return dictData
    }
    
    //MARK: Preparing transaction task dict
    func createTransactionDictionary() -> [String:Any]{
        dictionary["payment_method"] = methodType
        dictionary["transaction_type"] = "deposit"
        dictionary["transaction_id"] = transactionId.text
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        
        return dictionary
    }
    
    //MARK: pops to back Screen
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: Code to copy text from TextField
    //. copys mobile number and saves to clipbaord
    @IBAction func copyButton(_ sender: Any) {
        let copiedString = mobileNumber.text
        UIPasteboard.general.string = copiedString
        DispatchQueue.main.async {
            self.showToast(message: "Copied", font: .systemFont(ofSize: 17.0))
        }
    }
    
    //MARK: Continue Btn pressed
    //. Transaction id is extract and create TransactionApi call
    //. onSucess naviagtes to Successful payment screen
    @IBAction func continueBtn(_ sender: Any) {
        if(CheckInternet.Connection()){
            
            if(transactionId.text != ""){
                activityLoader.isHidden = false
                activityLoader.startAnimating()
                
                ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.createTransaction, dictionary: createTransactionDictionary(), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Result) in
                    switch Result{
                    case .success(_):
                        DispatchQueue.main.async { [self] in
                            activityLoader.isHidden = true
                            activityLoader.stopAnimating()
                            navigateToSuccessfulPayment()
                            
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            activityLoader.isHidden = true
                            activityLoader.stopAnimating()
                            presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                        }
                    }
                }
            }else{
                presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please Enter Transaction ID", comment: ""), parentController: self)
            }
            
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)
        }
    }
     
    //MARK: Sets Jazzcash/EasyPaisa Logo and text on basis of method type
    func setLogoImage(){
        
        logoImage.image = image
        logoImage.tintColor = .black
        
        if methodType != "easypaisa"{
            detailLable.text = NSLocalizedString("Our JazzCash account is active on this number", comment: "")
            transactionLabel.text = NSLocalizedString("* That is provided to you by JazzCash after your successful transaction", comment: "")
        }else{
            detailLable.text = NSLocalizedString("Our Easypaisa account is active on this number", comment: "")
            transactionLabel.text = NSLocalizedString("* That is provided to you by Easypasia after your successful transaction", comment: "")
            
        }
        
    }
    
    
    //MARK: Sets Styling to Continue Button
    func setButtonConstraints(){
        button.setTitleColor(UIColor(named: "AppTextColor"), for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowOpacity = 0.3
    }
    
    //MARK: Naviagte to SuccessfulPayment screen
    func navigateToSuccessfulPayment(){
        let storyboard = UIStoryboard(name: "MoodyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SuccessfulPaymentViewController") as! SuccessfulPaymentViewController
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Views are set
    //. MobileNumber is set to text field fetched from userDefault 
    func setViews(){
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.isNavigationBarHidden = true
        loader.isHidden = true
        screenText.text = screenTextLabel
        button.backgroundColor =  UIColor(named: "AccentColor")
        
    }
}

