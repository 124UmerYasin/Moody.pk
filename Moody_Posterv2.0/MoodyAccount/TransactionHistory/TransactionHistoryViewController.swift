//
//  TransactionHistoryViewController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 05/06/2021.
//

import Foundation
import UIKit

class TransactionHistoryViewController: UIViewController{
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var TaskHistoryCollectionView: UICollectionView!
    @IBOutlet weak var tasksTable: UITableView!{
        didSet{
            self.tasksTable.separatorStyle = .none
        }
    }
    @IBOutlet weak var NoHistoryLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var selectedMonth: Int = 0

    
    var data = [String:Any]()
    var transactionHistory = [[String:Any]]()
    
    let months = [NSLocalizedString("JAN", comment: ""), NSLocalizedString("FEB", comment: ""), NSLocalizedString("MAR", comment: ""), NSLocalizedString("APR", comment: ""), NSLocalizedString("MAY", comment: ""), NSLocalizedString("JUN", comment: ""), NSLocalizedString("JUL", comment: ""), NSLocalizedString("AUG", comment: ""), NSLocalizedString("SEP", comment: ""), NSLocalizedString("OCT", comment: ""), NSLocalizedString("NOV", comment: ""), NSLocalizedString("DEC", comment: "")]
    
    
    //MARK: calls when first time View Loads
    //.Shows Loader while fetching transactions
    //. selected month is selceted to current month
    //. delegates are set
    //. navigationBar is setup
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loaderUIUpdate(isAnimating: false)
        selectedMonth = Int(Date().currentMonth)! - 1
        registerNotifications()
        setDelegates()
        setupNavigationBar()
        setTransactionHistoryDictionary(date: Date().currentMonthAndYear)
        navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = NSLocalizedString("Transaction History", comment: "")
    }
    
    //MARK: Called to notify the view controller that its view has just laid out its subviews. Availability
    //. swipes collection view to current month 
    override func viewDidLayoutSubviews() {
        
        swipeToCurrentMonth(selectedMonth: selectedMonth)

    }
    
    //MARK: Action on right swipe button on calender
    @IBAction func rightbtn(_ sender: Any) {
        TaskHistoryCollectionView.selectItem(at: IndexPath(row: 11, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
    
    //MARK: Action on left swipe button on calender
    @IBAction func leftbtn(_ sender: Any) {
    
        TaskHistoryCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
    
    //MARK: Registers Notification Observer
    func registerNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.internetRunning(_:)), name: NSNotification.Name(rawValue: "checkInternetConnectionOnline"), object: nil)
    }
    
    
    //MARK: Check internet is running or not and make chages according to that
    @objc func internetRunning(_ notification: NSNotification) {
        
        DispatchQueue.main.async { [self] in
            setTransactionHistoryDictionary(date: Date().currentMonthAndYear)
        }
    }
    
    //MARK: Navigation Bar
    func setupNavigationBarBtn(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        let homeHeader = setNevTitleBtn()
        
        let btnBack = UIBarButtonItem(image:UIImage(named: "blackBackButton"), style: .plain, target: self, action: #selector(btnBackAction))
        
        self.navigationItem.leftBarButtonItems = [btnBack, homeHeader]
    }
    
    //MARK: Setup navigation bar title
    func setNevTitleBtn()-> UIBarButtonItem{

       let homeTitle = UILabel()
       homeTitle.attributedText = NSAttributedString(string:  NSLocalizedString("Transaction History", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0)])
       return UIBarButtonItem(customView: homeTitle)

    }
    
    //MARK: Pops back to MoodyAccount Screen
    @objc func btnBackAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Swipes month calender collection view to selected month
    func swipeToCurrentMonth(selectedMonth: Int) {
        TaskHistoryCollectionView.selectItem(at: IndexPath(row: selectedMonth, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
        
        TaskHistoryCollectionView.scrollToItem(at:IndexPath(item: selectedMonth, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    //MARK: Sets Table & CollectionView Delegates
    func setDelegates(){
        
        TaskHistoryCollectionView.delegate = self
        TaskHistoryCollectionView.dataSource = self
        tasksTable.dataSource = self
        tasksTable.delegate = self
        tasksTable.separatorStyle = .none
        tasksTable.register(UINib(nibName: "TransactionHistoryCell", bundle: nil), forCellReuseIdentifier: "TransactionHistoryCell")
        
    }
    
    //MARK: Prepares transactiona history api dictonary
    func setTransactionHistoryDictionary(date: String){
        
        var dictionary = [String:Any]()
        dictionary["date"] = date
        getTransactionsHistory(dictionary: dictionary)
        
    }
    
    //MARK: Transaction History Api call
    //. OnSuccess hostory is fetched and shown in table
    func getTransactionsHistory(dictionary: [String:Any]){
        if(CheckInternet.Connection()){
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.viewTransactionsHistory, dictionary: dictionary, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Results) in

                    switch Results{
                    case .success(let response):
                        if(response["transactions"] as? [[String:Any]] != nil){
                            self.transactionHistory = (response["transactions"] as? [[String:Any]])!
                            DispatchQueue.main.async { [self] in
                                loaderUIUpdate(isAnimating: true)
                                showTransactionHistory()
                            }
                        }else{
                            whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.viewTransactionsHistory, Key: "transactions")
                        }
                    case .failure(let error):
                        DispatchQueue.main.async { [self] in
                            presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                            loaderUIUpdate(isAnimating: true)
                            showTransactionHistory()
                        }
                    }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)

        }
    }
    
    //MARK: Shows loader and reloads collection and table view table 
    func showTransactionHistory(){
        
        loaderUIUpdate(isAnimating: true)
        if transactionHistory.count > 0{
            
        }else{
            NoHistoryLabel.isHidden = false
        }
        TaskHistoryCollectionView.reloadData()
        tasksTable.reloadData()
        
    }
    
    //MARK: Start and stop animating activity Loader.
    func loaderUIUpdate(isAnimating: Bool){
        
        NoHistoryLabel.isHidden = true
        loader.isHidden = isAnimating == true ? true : false
        isAnimating == true ? loader.stopAnimating() : loader.startAnimating()
        
    }
    
}
