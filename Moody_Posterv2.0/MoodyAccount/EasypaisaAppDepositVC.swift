//
//  EasypaisaAppDepositVC.swift
//  Moody_Posterv2.0
//
//  Created by Mobeen Rana on 02/09/2021.
//

import UIKit

class EasypaisaAppDepositVC: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var labelDepositDescription: UILabel!
    
    var dictionary = [String:Any]()
    
    
    //MARK: calls when first time View Loads
    //. Sets user mobile number
    //. set Ui and style on urdu lng check
    //. setTap Gesture to hideKeyboard
    //. Ui setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setUsersMobileNumber()
        setUrduLngStyle()
        setupToHideKeyboardOnTapOnView()
        textFieldLeftPadding(textFieldName: mobileNumber)
        textFieldLeftPadding(textFieldName: amount)
    }
    
    //MARK: Sets Users mobile number
    func setUsersMobileNumber(){
        if let number = UserDefaults.standard.string(forKey: DefaultsKeys.phone_number){
            mobileNumber.text = number.replacingOccurrences(of: "+92", with: "0")
        }
    }
    
    //MARK: UI styling if urdu lng is set 
    func setUrduLngStyle(){
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: labelDepositDescription, text: labelDepositDescription.text ?? "Found Nothing in labelDepositDescription", lineSpacing: 10)
            amount.attributedPlaceholder =  NSAttributedString(string: "Enter Amount", attributes: [.font: UIFont.systemFont(ofSize: 12) ])
        }
        amount.placeholder = NSLocalizedString("Enter Amount", comment: "")
    }
    
    //MARK: confirmBtn Tapped
    //. EasyPaisaApi Call
    @IBAction func confirmBtn(_ sender: Any) {
        easyPaisaApiCall()
    }
    
    //MARK: EasyPaisa Api call
    //. OnSuccess dialog with amount is shown
    func easyPaisaApiCall(){
        if(CheckInternet.Connection()){
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.easyPaisaAppFlow, dictionary: creatEasyPaisaDict(), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Result) in
                switch Result{
                case .success(_):
                    DispatchQueue.main.async { [self] in
                        let vc = AlertService().presentEasyPaisaPayAlert()
                        self.present(vc, animated: true, completion: nil)
                        if let Amount = amount {
                            vc.depositAmount.text = Amount.text
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                    }
                }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)
        }
    }
    
    //MARK: Pops back to EasyPaisa Screen
    @IBAction func BackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Prepares EasyPaisa Deposit Api Dictioanry
    func creatEasyPaisaDict() -> [String:Any]{
        
        dictionary["amount"] = amount.text
        dictionary["phone_number"] = mobileNumber.text
        return dictionary
    }
    
    
    
}
