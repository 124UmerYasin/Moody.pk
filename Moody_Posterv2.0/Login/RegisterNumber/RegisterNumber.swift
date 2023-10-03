//
//  RegisterNumber.swift
//  Moody_Posterv2.0
//
//  Created by   on 03/06/2021.
//

import Foundation
import UIKit

class RegisterNumber : UIViewController{
    
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var errorLable: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var checkRadioBtn: UIButton!
    @IBOutlet weak var checkRadioImg: UIImageView!
    @IBOutlet weak var termAndConditionText: UILabel!
    
    static var otp: Int?
    static var number: String?
    var termsAndConditionBool: Bool = false
    var number: String?
    
    
    //MARK: calls when first time View Loads
    //. Ui styling
    //. Navigation bar styling
    //. Add Tap Gesture on terms&condition Btn
    override func viewDidLoad() {
        addRadiusAndShadow()
        setupToHideKeyboardOnTapOnView()
        setupNavigationBar()
        viewInitializion()
        inilizeNumberView()
        addTapGesture()
        numberTextField.delegate = self
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: Calls just before view appears
    //. Disables swipe gesture and hides navigationBar
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: Terms&Conditon Page is open
    //. On webView Moody terms and condition opens on new Screen
    @objc func onTermsClickPressed(_ sender: UIGestureRecognizer){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MoodyTerms_Conditions") as! MoodyTerms_Conditions
        self.present(nextViewController, animated:true, completion:nil)

    }
    
    //MARK: View is inistailised
    //. keypad open and Numbertextfiled selected
    //. continue button disabled
    func viewInitializion(){
        navigationController?.isNavigationBarHidden = false
        numberTextField.becomeFirstResponder()
        disableBtn(continueBtn)
    }
    
    //MARK: NumberView inistilise and view Styling
    func inilizeNumberView(){
        numberView.layer.borderWidth = 1.3
        numberView.layer.masksToBounds = true
        numberView.layer.cornerRadius = 3
        numberView.layer.borderColor = UIColor(named: "ButtonColor")?.cgColor
        numberView.layer.borderColor = UIColor(named: "AppTextColor")?.cgColor
    }
    
    
    //MARK: TapGesture of terms and condition
    func addTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action:  #selector (self.onTermsClickPressed(_:)))
        self.termAndConditionText.isUserInteractionEnabled = true
        self.termAndConditionText.addGestureRecognizer(tap)
    }
    
    func addRadiusAndShadow(){
        continueBtn.layer.cornerRadius = 5.0
    }
    
    //MARK: Radio Buttton check/uncheck
    //.checks the terms&condtion checkbox and enables continue btn if number is valid and bool is true
    @IBAction func checkRadioBtnPressed(_ sender: Any) {
        if(termsAndConditionBool){
            checkRadioImg.image = UIImage(named: "unCheckBtn")
            termsAndConditionBool = false
            if((numberTextField.text?.count)! > 0){
                textHandling(text: numberTextField.text!, textfield: numberTextField)
            }
            disableBtn(continueBtn)
        }else{
            checkRadioImg.image = UIImage(named: "checkBtn")
            termsAndConditionBool = true
            
            if((numberTextField.text?.count)! > 0){
                checkCount(text: numberTextField.text!, textfield: numberTextField, number: numberTextField.text!.count)
                let continueBtnFlg = textHandling(text: numberTextField.text!, textfield: numberTextField)
                if(continueBtnFlg){
                    enableBtn(continueBtn)
                }else{
                    disableBtn(continueBtn)
                }
            }
        }
    }
    
    //MARK: Continue Button Tapped
    //. Internet check,number validation check
    //. Register Number Api call
    @IBAction func continueTap(_ sender: Any) {
        if(CheckInternet.Connection()){
            if(numberTextField.text!.count > 0){
                guard let num = numberTextField.text else {return}
                number = num
                if isVaildNumber(number!){
                    disableBtn(continueBtn)
                    termAndConditionText.isUserInteractionEnabled = false
                    registerNumAPI()
                }else{
                    termAndConditionText.isUserInteractionEnabled = true
                    errorLable.isHidden = false
                }
            }else{
                termAndConditionText.isUserInteractionEnabled = true
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "please enter valid number", comment: ""), parentController: self)
            }
        }else{
            DispatchQueue.main.async {
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "Internet Not Available. Please check your internet connection and try again.", comment: ""), parentController: self)
            }
        }
    }
}


