//
//  TopupVC.swift
//  Moody_Posterv2.0
//
//  Created by   on 30/07/2021.
//

import Foundation
import UIKit

class TopupVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var amountTextBox: UITextField!
    @IBOutlet weak var MaxAmountLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    //MARK: Variables
    var topupAmount = 0
    var minAmount = 500
    var maxAmount = 10000
    
    //MARK: calls when first time View Loads
    //. Set amountTextBox Delegate
    //. SetNavigationBar
    //. Set max/min amount of topUp
    //. Disables sendBtn
    //. localise string
    override func viewDidLoad() {
        amountTextBox.delegate = self
        setupNavigationBar()
        setupToHideKeyboardOnTapOnView()
        setVisibility()
        setMaxMinAmount()
        disableBtn(sendBtn)
        localiseUrduString()
    }
    
    //MARK: Calls just before view appears
    //. Localise UrduString
    //. start updating location
    override func viewWillAppear(_ animated: Bool) {
        localiseUrduString()
        amountTextBox.text = ""
        LocationManagers.locationSharesInstance.startUpdatingLocations()
    }
    
    //MARK: Sets visibility of loader/navigationController
    func setVisibility(){
        loader.isHidden = true
        navigationController?.isNavigationBarHidden = false
    }
    
    
    //MARK: Localise TopUp string
    func localiseUrduString(){
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            self.navigationItem.title = "ٹاپ اپ"
        }else{
            self.navigationItem.title = "TopUp"
        }
    }
    
    //MARK: Sets Max/Min amount of Topup
    func setMaxMinAmount(){
        minAmount = Int(UserDefaults.standard.string(forKey: DefaultsKeys.minimum_amount_for_top_up)!) ?? 500
        maxAmount = Int(UserDefaults.standard.string(forKey: DefaultsKeys.maximum_top_up_amount)!) ?? 10000
    }
    
    //MARK: Send button tapped
    //. TopUp taskAmount limit checks
    //. Ui changes and create topUp Task api call
    @IBAction func sendDidTap(_ sender: Any) {
        
        topupAmount = Int(amountTextBox.text!)!
        if(topupAmount <= UserDefaults.standard.integer(forKey: DefaultsKeys.maximum_top_up_amount) && topupAmount >= UserDefaults.standard.integer(forKey: DefaultsKeys.minimum_amount_for_top_up)){
            DispatchQueue.main.async { [self] in
                disableBtn(sendBtn)
                self.navigationController?.navigationBar.isUserInteractionEnabled = false
                loader.isHidden = false
                loader.startAnimating()
            }
            createTopUpTaskAPICall()
        }
        else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Top up amount should be between \(UserDefaults.standard.integer(forKey: DefaultsKeys.minimum_amount_for_top_up)) and \(UserDefaults.standard.integer(forKey: DefaultsKeys.maximum_top_up_amount))", comment: ""), parentController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        LocationManagers.locationSharesInstance.stopLocationUpdate()
    }
    
    
    //MARK: Delegate to detect when textField selection change
    //. TopUp Amount limit checks and Ui changes
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        topupAmount = Int(amountTextBox.text!) ?? 0
        
        if ((topupAmount >= UserDefaults.standard.integer(forKey: DefaultsKeys.minimum_amount_for_top_up)) && (topupAmount <= UserDefaults.standard.integer(forKey: DefaultsKeys.maximum_top_up_amount))){
            enableBtn(sendBtn)
            MaxAmountLbl.isHidden = true
        }else{
            disableBtn(sendBtn)
            MaxAmountLbl.isHidden = false
        }
    }
    
    
    //MARK: Prepares createTopUp Task Dictonary
    func createTopupTaskDictionary() -> [String:Any]{
        
        var loc = LocationManagers.locationSharesInstance.getUpdatedLocation()
        if(loc.coordinate.latitude == 0.0 || loc.coordinate.longitude == 0.0){
            loc = LocationManagers.locationSharesInstance.getUpdatedLocation()
        }
        var dictData = [String:Any]()
        dictData["poster_location"] = "\(loc.coordinate.latitude), \( loc.coordinate.longitude)"
        dictData["amount"] = Int(amountTextBox.text!)
        dictData["type"] = "top_up"
        dictData["user_agent"] = AppPermission.getDeviceInfo()
        dictData["platform"] = "ios"
        
        return dictData
    }
    
    //MARK: TopUp Task Api call
    //. OnSucess QbDetails are fetched from response and saved in local UserDefaults
    //. QbLogs in and navigates to chatViewController
    func createTopUpTaskAPICall(){
        if(CheckInternet.Connection()){
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.create_top_up_task, dictionary: createTopupTaskDictionary(), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] Result in
                switch Result{
                case .success(let response):
                    DispatchQueue.main.async {
                        
                        response["task_id"] as? String != nil ? UserDefaults.standard.setValue(response["task_id"] as! String, forKey: DefaultsKeys.taskId) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.create_top_up_task, Key: "task_id")
                        UserDefaults.standard.setValue("top_up", forKey: DefaultsKeys.taskType)
                        let qbDetails = response["quickblox_data"] as? [String:Any] ?? [String:Any]()
                        
                        qbDetails["qb_id"] as? Int != nil ? UserDefaults.standard.set(qbDetails["qb_id"] as? Int ?? nil, forKey: DefaultsKeys.qb_id) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.createTask, Key: "qb_id")
                        qbDetails["password"] as? String != nil ? UserDefaults.standard.set(qbDetails["password"] as? String ?? "", forKey: DefaultsKeys.qb_password) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.createTask, Key: "password")
                        qbDetails["login"] as? String != nil ? UserDefaults.standard.set(qbDetails["login"] as? String ?? "", forKey: DefaultsKeys.qb_login) : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.createTask, Key: "login")
                        
                        let isQbLogin = UserDefaults.standard.bool(forKey: DefaultsKeys.isQbLogin)
                        
                        if((qbDetails["login"] as? String != "") && isQbLogin == false){
                                loginQb()
                        }else if(isQbLogin == true) {
                            print("User Already loggedIn")
                        }
                        
                        let vc = ExtendedChat()
                        vc.hidesBottomBarWhenPushed = true
                        enableBtn(sendBtn)
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        loader.isHidden = true
                        loader.stopAnimating()
                        LocationManagers.locationSharesInstance.stopLocationUpdate()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    break
                    
                case .failure(let error):
                                    
                    DispatchQueue.main.async {
                        enableBtn(sendBtn)
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        loader.isHidden = true
                        loader.stopAnimating()
                        self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                    }
                    
                    break
                }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)
        }
    }
        
    //MARK: QbLogin notification is post to login to qb
    func loginQb(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "qbLogin"), object: nil)
        }
    }
}


//MARK: TextFields Delegates
extension TopupVC: UITextFieldDelegate {
    
    
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
    
    //MARK: Handling of TextField
    //. Enables and disables button of continueBtn check on amount 
    func fieldsHandling(string: String, textField: UITextField, textCount: Int) -> Bool{
        
        let amountInt: Int = Int(textField.text! + string) ?? 0
        
        if amountInt >= minAmount && amountInt <= maxAmount {
            enableBtn(sendBtn)
        }else{
            disableBtn(sendBtn)
        }
        return true
    }
    
}
