//
//  AskQuestionViewController.swift
//  Moody_Posterv2.0
//
//  Created by Mobeen Rana on 07/09/2021.
//

import UIKit

class AskQuestionViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    //MARK: Variables
    static var askQuestionVisible = false
    var dictionary = [String:Any]()
    
    
    //MARK: calls when first time View Loads
    //. Styling to views
    //. TapGesture to hide keypad
    override func viewDidLoad() {
        super.viewDidLoad()
        giveBorderToView(view: myView)
        setupToHideKeyboardOnTapOnView()
        activityLoader.isHidden = true
    }
    
    //MARK: Calls just before view appears
    //. Subject text filed is setup
    override func viewWillAppear(_ animated: Bool) {
        
        AskQuestionViewController.askQuestionVisible = true
        self.navigationController?.navigationBar.isHidden = true
        setSubjectTextField()
    }
    
    //MARK: Calls on view disappears
    //. bool reset
    override func viewWillDisappear(_ animated: Bool) {
        AskQuestionViewController.askQuestionVisible = false
    }
    

    //MARK: - IBActions
    
    //MARK: Submits newTicket
    @IBAction func submitBtn(_ sender: Any) {
        creatTicketAPI()
    }
    
    //MARK: Pops to back Ticket History Screen
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
                        //MARK: Functions
    
    //MARK: Generic function to style views
    func giveBorderToView(view: UIView){
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
    }
    
    func setSubjectTextField(){
        subjectTextField.text = ""
        subjectTextField.placeholder = NSLocalizedString("Enter your subject here", comment: "")
        subjectTextField.keyboardType = .twitter
        subjectTextField.returnKeyType = .done
    }
    
    func checkProfileIcon(){
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            tabBarController?.tabBar.items![3].image = UIImage(named:"notifiedSelectedProfile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
        }
    }
    
}

//MARK: - API Call
extension AskQuestionViewController {
    
    //MARK: CreateTicket Api Call
    //. On api success new ticket is generated and Customer screen is pushed
    func creatTicketAPI(){
        if(CheckInternet.Connection()){
            submitButton.isUserInteractionEnabled = false
            submitButton.alpha = 0.5
            activityLoader.isHidden = false
            activityLoader.startAnimating()
                ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.createTicket, dictionary: createTicketDict(), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Result) in
                    print(Result)
                    switch Result{
                    case .success(let response):
                        
                        if response["_id"] as? String != nil  {
                            DispatchQueue.main.async { [self] in
                                let vc = CustomerSupport()
                                vc.hidesBottomBarWhenPushed = true
                                vc.ticket_id = response["_id"] as! String
                                vc.ticketIdForChat = response["ticket_id"] as! String
                                vc.status = true
                                self.navigationController?.pushViewController(vc, animated: true)
                                submitButton.isUserInteractionEnabled = true
                                submitButton.alpha = 1.0
                                activityLoader.isHidden = true
                                activityLoader.stopAnimating()
                        }
                }
                    case .failure(let error):
                        
                        DispatchQueue.main.async {
                            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                            submitButton.isUserInteractionEnabled = true
                            submitButton.alpha = 1.0
                            activityLoader.isHidden = true
                            activityLoader.stopAnimating()
                        }
                    }
                }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)
        }
    }
    
    //MARK: Prepares Dict for createTicket Api
    func createTicketDict() -> [String:Any]{
        dictionary["subject"] = subjectTextField.text
        return dictionary
    }
}

