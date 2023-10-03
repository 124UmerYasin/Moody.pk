//
//  SelectPaymentMethodViewController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 05/06/2021.
//

import Foundation
import UIKit

class SelectPaymentMethodViewController: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var payInHandLabel: UILabel!
    @IBOutlet var amount: UILabel!
    @IBOutlet var Loader: UIActivityIndicatorView!
    @IBOutlet var easypaisaNumber: UILabel!
    @IBOutlet var jazzcashNumber: UILabel!
    @IBOutlet var viewReceiptBtn: UIButton!
    @IBOutlet var seeTransactionsBtn: UIButton!
    @IBOutlet var paymentLabel: UILabel!
    @IBOutlet weak var promoAmount: UILabel!
    @IBOutlet weak var payInHandMoodyLabel: UILabel!
    @IBOutlet weak var viewPromoBalance: UIView!
    @IBOutlet weak var jazzCashBtn: UIButton!
    @IBOutlet weak var easyPaisaBtn: UIButton!
    @IBOutlet weak var moodyBtn: UIButton!
    @IBOutlet weak var rightArrow2: UIImageView!
    @IBOutlet weak var rightArrow3: UIImageView!
    @IBOutlet weak var rightArrow1: UIImageView!
    
    //MARK: Variables
    static var PaymentType:String!
    var hasComeFromTask = false
    
    //MARK: underline code for see transactions button
    let underLine: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Gilroy-Bold", size: 20) ?? .systemFont(ofSize: 20),
          .underlineStyle: NSUnderlineStyle.single.rawValue
      ]
    //MARK: calls when first time View Loads
    //. Setup ui on basis on language
    //. Register NotificationObserver
    //. set wallet/promo balance data
    //. Exclusive button touch
    //. Add Swipe gesture
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUi()
        registerNotification()
        setData()
        setBtnExclusiveTouch()
        addSwipeGestures()
        self.setupNavigationBarBtn()
    }
    
    //MARK: Calls just before view appears
    //. Setup ui on basis on language
    //. setWalletData()
    //. SetBar button
    //. setNavigationBar visibility
    override func viewWillAppear(_ animated: Bool) {
        SetupUi()
        setWalletData()
        self.setupNavigationBarBtn()
        setNavigationVisibility()
    }
    
    //MARK: Sets visibility of TabBar/NaviagtionBar
    func setNavigationVisibility(){
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: Sets prmount/wallet balance of user to labels
    func setWalletData(){
        amount.text = UserDefaults.standard.string(forKey: DefaultsKeys.wallet_balance)
        if(UserDefaults.standard.string(forKey: DefaultsKeys.promo_balance) != nil){
            promoAmount.text = UserDefaults.standard.string(forKey: DefaultsKeys.promo_balance)
        }else{
            
            promoAmount.text = "0"
        }
    }
    
    func SetupUi(){
        if UserDefaults.standard.string(forKey: "language") != "ur-Arab-PK"{
            let attributeString = NSMutableAttributedString(
                    string: NSLocalizedString("See Transactions", comment: ""),attributes: underLine
                 )
            
            seeTransactionsBtn.setAttributedTitle(attributeString, for: .normal)
        }else{
            rightArrow1.image = UIImage(named: "left-arrow")
            rightArrow2.image = UIImage(named: "left-arrow")
            rightArrow3.image = UIImage(named: "left-arrow")
            setTextWithLineSpacing(label: payInHandMoodyLabel, text: payInHandMoodyLabel.text ?? "Empty Found in payInHandMoodyLabel", lineSpacing: 6)
            payInHandMoodyLabel.font = .systemFont(ofSize: 18)
            payInHandMoodyLabel.textAlignment = .right
            
            setTextWithLineSpacing(label: payInHandLabel, text: payInHandLabel.text ?? "Found Nothing in selectLanguageLabel", lineSpacing: 4)
            payInHandLabel.textAlignment = .right
        }
    }
    
    //MARK: Checks profile icon badge
    func checkProfileBadge(){
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileBadge")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
           
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
        }
    }
    //MARK: Set Moody Jazz/EasyPaisa number to
    func setData(){
        
        easypaisaNumber.text = NSLocalizedString("Easypaisa", comment: "")
        //easypaisaNumber.text = UserDefaults.standard.string(forKey: DefaultsKeys.moody_phone_number)
        jazzcashNumber.text = UserDefaults.standard.string(forKey: DefaultsKeys.moody_phone_number)
    }
    
    
    //MARK: Set exclusive touch to buttons
    func setBtnExclusiveTouch(){
        navigationController?.isNavigationBarHidden = true
        easyPaisaBtn.isExclusiveTouch = true
        jazzCashBtn.isExclusiveTouch = true
        moodyBtn.isExclusiveTouch = true
    }
    
    //MARK: Registers Notification observers
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateWallet(_:)), name: NSNotification.Name(rawValue: "walletUpdate"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateWallet(_:)), name: NSNotification.Name(rawValue: "promoBalance"), object: nil)
    }
    
    
    
    func setUrduLngPostion(){
        if UserDefaults.standard.string(forKey: "language") == "ur-Arab-PK"{
            setTextWithLineSpacing(label: payInHandLabel, text: payInHandLabel.text ?? "Found Nothing in selectLanguageLabel", lineSpacing: 4)
            payInHandLabel.textAlignment = .right
        }
    }
    
    
    //MARK: Updates wallet balance
    //. This method is called when Update balance notification/emit is received to update wallet/promo balance of user
    @objc func updateWallet(_ notification:NSNotification){
        amount.text = UserDefaults.standard.string(forKey: DefaultsKeys.wallet_balance)
        if(UserDefaults.standard.string(forKey: DefaultsKeys.promo_balance) != nil){
            promoAmount.text = UserDefaults.standard.string(forKey: DefaultsKeys.promo_balance)
        }else{
            promoAmount.text = "0"
        }
    }
    
    //MARK: Navigate to EasyPaisa Screen
    @IBAction func easypaisaPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MoodyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EasypaisaAppDepositVC") as! EasypaisaAppDepositVC
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Navigate to Jazz cash Screen
    @IBAction func jazzcashPressed(_ sender: Any) {
        navigateToConfirmPayment(image: UIImage(named: "jaz imagepng")!, lable:  NSLocalizedString("Please send your desired amount \n to account via nearby JazzCash shop.",comment: ""), type: "jazzcash")
    }
    
    //MARK: Navigate to TopUp screen Screen
    @IBAction func moodyPressed(_ sender: Any) {
        navigateToNextScreen("MoodyAccount", "TopupVC")
    }
    

    
    //MARK: Navigate to Transactions Screen
    @IBAction func viewTransactions(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "MoodyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TransactionHistoryViewController") as! TransactionHistoryViewController
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK: Initilizing the navigation bar
    func setupNavigationBarBtn(){
        setupNavigationBar()
    }

    
    //MARK: Navigate to confirm payment screen.
    func navigateToConfirmPayment(image: UIImage, lable: String, type: String){
        
        let storyboard = UIStoryboard(name: "MoodyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ConfirmPaymentViewController") as! ConfirmPaymentViewController
        let origImage = image
        vc.image = origImage
        vc.methodType = type
        vc.screenTextLabel = lable
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK: Navigation bar UI changes
    func navigationBarUpdate(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        navigationItem.title = " "
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.4
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    
}
