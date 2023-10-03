//
//  TaskHistoryController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit

class TaskHistoryViewController: UIViewController {
  
    
    static var isScreenVisible:Bool!
    var selectedMonth:Int = 0
    
    var data = [String:Any]()
    var tasksHistory = [[String:Any]]()
    
    var fileManager : FileManager?
    var documentDir : NSString?
    var filePath : NSString?
    
    @IBOutlet weak var TaskHistoryCollectionView: UICollectionView!
    @IBOutlet weak var tasksTable: UITableView!
    @IBOutlet weak var NoHistoryLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var yearLbl: UILabel!
    
    
    
    let months = [NSLocalizedString("JAN", comment: ""), NSLocalizedString("FEB", comment: ""), NSLocalizedString("MAR", comment: ""), NSLocalizedString("APR", comment: ""), NSLocalizedString("MAY", comment: ""), NSLocalizedString("JUN", comment: ""), NSLocalizedString("JUL", comment: ""), NSLocalizedString("AUG", comment: ""), NSLocalizedString("SEP", comment: ""), NSLocalizedString("OCT", comment: ""), NSLocalizedString("NOV", comment: ""), NSLocalizedString("DEC", comment: "")]
    
    
    //MARK: calls when first time View Loads
    //. Set current year
    //. setup NavigationBar
    //. RegisterNotifcation observers
    //. add swipe gesture to move on tabbar options
    override func viewDidLoad() {
        super.viewDidLoad()
        TaskHistoryViewController.isScreenVisible = true
        navigationController?.isNavigationBarHidden = true
        setYear()
        setupNavigationBar()
        registerNotifications()
        setDelegates()
        addSwipeGestures()

    }
    
    //MARK: Calls when screen sub views are ready
    //. swipes to current month
    override func viewDidLayoutSubviews() {
        if(DefaultsKeys.historyYearCheck){
            swipeToCurrentMonth(selectedMonth: UserDefaults.standard.integer(forKey: DefaultsKeys.selectedHistoryMonth))
            DefaultsKeys.historyYearCheck = false
        }else{
            swipeToCurrentMonth(selectedMonth: selectedMonth)
        }
    }
    //MARK: Calls just before view appears
    //. Checks Profile Tab Badge
    //. SwipesToSelectedMonth
    //. Set Navigation/Tabbar visibility
    override func viewWillAppear(_ animated: Bool) {
        checkProfileBadge()
        swipeToSelectedMonth()
        setVisibility()
    }
    
    //MARK: Calls just before view disappears
    //. Notifation observer is post of goingOut from history
    //. Screen visibility Bool is reset
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "goingOutFromHistory"), object: nil)
        TaskHistoryViewController.isScreenVisible = false
    }
    

    //MARK: NavigationBar and TabBar Visibility is set
    func setVisibility(){
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    //MARK: Checks badge of profile bottom TabBar icon
    func checkProfileBadge(){
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileBadge")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
           
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
        }
    }
    
    //MARK: Swipes collection to selected month 
    func swipeToSelectedMonth(){
        if(DefaultsKeys.historyYearCheck){
            selectedMonth = UserDefaults.standard.integer(forKey: DefaultsKeys.selectedHistoryMonth)
            setTasksHistoryDictionary(date: UserDefaults.standard.string(forKey: DefaultsKeys.selectedDate) ?? Date().currentMonthAndYear)
            swipeToCurrentMonth(selectedMonth: selectedMonth)
        }else{
            selectedMonth = Int(Date().currentMonth)! - 1
            setTasksHistoryDictionary(date: Date().currentMonthAndYear)
            swipeToCurrentMonth(selectedMonth: selectedMonth)
        }
    }
    
    
    
    //MARK: Sets current year of Task History
    func setYear(){
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        yearLbl.text = String(year)
    }
    
    
    
    

    
    //MARK: Registers Notification Observers
    func registerNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(reload(_:)), name: NSNotification.Name(rawValue: "reloadViewAftercancelTask"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internetRunning(_:)), name: NSNotification.Name(rawValue: "checkInternetConnectionOnline"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateHistoryData(_:)), name: NSNotification.Name(rawValue: "updateHistoryData"), object: nil)
    }
    
    
    //MARK: Check internet is running or not and make chages according to that
    @objc func internetRunning(_ notification: NSNotification) {
        let date: String
        if(selectedMonth < 9){
            date = "\(Date().currentYear)-0\(selectedMonth + 1)"
        }
        else{
            date = "\(Date().currentYear)-\(selectedMonth + 1)"
        }
        DispatchQueue.main.async { [self] in
            setTasksHistoryDictionary(date: date)
        }
    }
        
    
    //MARK: Updates task history
    //. Method is called when updateHistoryData emit is received
    //. Method receive data from emit and taskTicket History is updated
    @objc func updateHistoryData(_ notification:NSNotification){
        let data = notification.userInfo as! [String:Any]
        for (index, _) in tasksHistory.reversed().enumerated() {
            if(data["_id"] as! String == tasksHistory[index]["_id"] as! String){
                tasksHistory[index]["type"] = data["type"] as? String
                tasksHistory[index]["poster_notification_count"] = data["poster_notification_count"] as! Int
                tasksHistory[index]["status"] = data["status"] as! String
                tasksHistory[index]["run_time_fare"] = data["run_time_fare"] as? String ?? "0"
            }
        }
        tasksTable.reloadData()
    }


    
    
    //MARK: Action on right swipe button on calender
    @IBAction func rightbtn(_ sender: Any) {
        TaskHistoryCollectionView.selectItem(at: IndexPath(row: 11, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
    
    //MARK: Action on left swipe button on calender
    @IBAction func leftbtn(_ sender: Any) {
        TaskHistoryCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
    


    //MARK: Setup navigation bar title
    func setNevTitleBtn()-> UIBarButtonItem{

       let homeTitle = UILabel()
       homeTitle.attributedText = NSAttributedString(string:  NSLocalizedString("Task History", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0)])
       return UIBarButtonItem(customView: homeTitle)

    }
    

    //MARK: Swipe to current month
    //. Method recieves intger of current month and it swipes month collection view to current month
    func swipeToCurrentMonth(selectedMonth: Int) {
       //TaskHistoryCollectionView.selectItem(at: IndexPath(row: selectedMonth, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
        TaskHistoryCollectionView.scrollToItem(at:IndexPath(item: selectedMonth, section: 0), at: .centeredHorizontally, animated: true)
    
    }
    
    //MARK: Registers TableView & ColletionView Delegates
    func setDelegates(){
        
        TaskHistoryCollectionView.delegate = self
        TaskHistoryCollectionView.dataSource = self
        tasksTable.dataSource = self
        tasksTable.delegate = self
        tasksTable.separatorStyle = .none
        tasksTable.register(UINib(nibName: "TaskHistoryCell", bundle: nil), forCellReuseIdentifier: "TaskHistoryCell")
        
    }
    
    //MARK: Prepare Dictonary for taskHistory Api call
    //. Receives date in method
    //. sets date in dict
    //. prepared dictonary is sent in getTasksHistory method
    func setTasksHistoryDictionary(date: String){
        var dictionary = [String:Any]()
        dictionary["date"] = date
        getTasksHistory(dictionary: dictionary)
    }
    
    //MARK: Task History Api call
    //. OnSuccess response is fetched and saved in global taskHistory dict
    //. ShowTaskHistory is called to reloadTable view
    func getTasksHistory(dictionary: [String:Any]){
        if(CheckInternet.Connection()){
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.readTaskHistory, dictionary: dictionary, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Results) in

                    switch Results{
                    case .success(let response):
                        self.tasksHistory = (response["tasks"] as? [[String:Any]])!
                        
                        DispatchQueue.main.async { [self] in
                            self.tasksTable.isUserInteractionEnabled = true
                            loaderUIUpdate(isAnimating: true)
                            showTaskHistory()
                        }
                    case .failure(let error):
                        DispatchQueue.main.async { [self] in
                            self.tasksTable.isUserInteractionEnabled = true
                            presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                            loaderUIUpdate(isAnimating: true)
                            showTaskHistory()
                        }
                    }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)
        }
    }
    
    //MARK: Check task history count and Reloads and task history TableView and month CollectionView
    func showTaskHistory(){
        
        loaderUIUpdate(isAnimating: true)
        if tasksHistory.count <= 0 {
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
    
    //MARK: Updates task history
    //. Method is called when updateHistoryData emit is received
    //. Method receive data from emit and Task History is updated
    @objc func reload(_ notification:NSNotification){
        selectedMonth = Int(Date().currentMonth)! - 1
        setTasksHistoryDictionary(date: Date().currentMonthAndYear)
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
    }
}
