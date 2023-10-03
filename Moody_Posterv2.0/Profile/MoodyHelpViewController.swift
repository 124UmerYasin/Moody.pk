//
//  MoodyHelpViewController.swift
//  Moody_Posterv2.0
//
//  Created by Mobeen Rana on 06/09/2021.
//
import UIKit
import Foundation

class MoodyHelpViewController: UIViewController {
    
    var selectedMonth:Int = 0
    var ticketHistory = [[String:Any]]()
    var data = [String:Any]()
    
    let months = [NSLocalizedString("JAN", comment: ""), NSLocalizedString("FEB", comment: ""), NSLocalizedString("MAR", comment: ""), NSLocalizedString("APR", comment: ""), NSLocalizedString("MAY", comment: ""), NSLocalizedString("JUN", comment: ""), NSLocalizedString("JUL", comment: ""), NSLocalizedString("AUG", comment: ""), NSLocalizedString("SEP", comment: ""), NSLocalizedString("OCT", comment: ""), NSLocalizedString("NOV", comment: ""), NSLocalizedString("DEC", comment: "")]
    


    //MARK: - IBOutlets
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var myMonthCollectionView: UICollectionView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var NoHistoryLabel: UILabel!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    
    static var MoodyHelpViewControllerVisible = false
    
    
    //MARK: calls when first time View Loads
    //. Sets TableView
    //. Sets CollectionView
    //. RegsiterNotifiaction observers
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView() //configuring table view delegates
        configureCollectionView() //configuring collection view delegates
        registerNotifications()
    }
    
    //MARK: Calls when viewDisappears
    //. resets HelpViewController bool
    override func viewWillDisappear(_ animated: Bool) {
        MoodyHelpViewController.MoodyHelpViewControllerVisible = false
    }
    
    //MARK: Calls when view is about to appear
    //. checks tabBar profile icon badge
    //. Navigation/TabBar visibility
    //. TicketHistory Dictonary is set with month and year to fetch ticket history
    //. RegisterNotifcations observers
    override func viewWillAppear(_ animated: Bool) {
        checkProfileBadge()
        setVisibilty()
        selectedMonth = Int(Date().currentMonth)! - 1
        setTicketHistoryDictionary(date: Date().currentMonthAndYear)
        registerNotifications()
    }
    
    //MARK: Called to notify the view controller that its view has just laid out its subviews
    //. swipes collection view to selected month
    override func viewDidLayoutSubviews() {
        swipeToCurrentMonth(selectedMonth: selectedMonth)
    }
    
                                //MARK: -IBActions
    
    //MARK: Navigate to Creates new Ticket Screen
    @IBAction func addTicketBtn(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "AskQuestionViewController") as! AskQuestionViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK: Scroll top Months collectionView to left
    @IBAction func leftMonthBtnOnClick(_ sender: Any) {
        myMonthCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)

    }
    //MARK: Scroll top Months collectionView to right
    @IBAction func rightBtnOnClick(_ sender: Any) {
        myMonthCollectionView.selectItem(at: IndexPath(row: 11, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
    
    //MARK: Pops back to settings screen
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Functions
    
    //MARK: Checks and Sets Profile icon Image in TabBar
    func checkProfileBadge(){
        if(UserDefaults.standard.bool(forKey: DefaultsKeys.helpBadge)){
            tabBarController?.tabBar.items![3].image = UIImage(named:"notifiedSelectedProfile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
        }else{
            tabBarController?.tabBar.items![3].image = UIImage(named:"profileNew")
        }
    }
    //MARK: Set Navigation/TabBar visbilities 
    func setVisibilty(){
        MoodyHelpViewController.MoodyHelpViewControllerVisible = true
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    func setYear(){
        
        let date = Date()
        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)
        yearLbl.text = String(year)
    }
    
    
    //MARK: Prepare Dictonary for ticketHistory Api call
    //. Receives date in method
    //. sets date in dict
    //. prepared dictonary is sent in helpApiCall method
    func setTicketHistoryDictionary(date: String){
        
        self.myTableView.isUserInteractionEnabled = false
        var dictionary = [String:Any]()
        dictionary["date"] = date
        helpApiCall(dictionary:dictionary)
    }
    
    
    
    
    
    //MARK: Reloads TicketHistory CollectionView
    //. Sends current month to prepare dict for ticketHistory Api
    //. Reloads updated data
    @objc func reload(_ notification:NSNotification){
        selectedMonth = Int(Date().currentMonth)! - 1
        setTicketHistoryDictionary(date: Date().currentMonthAndYear)
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
    
    //MARK: Registers NotifiactionObserver
    func registerNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(reload(_:)), name: NSNotification.Name(rawValue: "reloadViewAftercancelTask"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTick(_:)), name: NSNotification.Name(rawValue: "updateTickStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internetRunning(_:)), name: NSNotification.Name(rawValue: "checkInternetConnectionOnline"), object: nil)
    }

    //MARK: Swipe to current month
    //. Method recieves intger of current month and it swipes month collection view to current month
    func swipeToCurrentMonth(selectedMonth: Int) {
        myMonthCollectionView.selectItem(at: IndexPath(row: selectedMonth, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
        
        myMonthCollectionView.scrollToItem(at:IndexPath(item: selectedMonth, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    //MARK: Updates TicketHistory when internet connects back
    //. When intenet reconnects method is called
    //. date is set from users selected month
    //. date is sent to prepare dict for ticketHistory api call
    @objc func internetRunning(_ notification: NSNotification) {
        
        let date: String
        
        if(selectedMonth < 9){
            date = "\(Date().currentYear)-0\(selectedMonth + 1)"
            
        }
        else{
            date = "\(Date().currentYear)-\(selectedMonth + 1)"
        }
        
        DispatchQueue.main.async { [self] in
            setTicketHistoryDictionary(date: date)
        }
    }
    
    func addLabelTextAndSendWebHook(label:UILabel? = nil ,name:String){
           if(label != nil){
               label!.text = ""
           }
           whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.ticketHistory, Key: "\(name)")
       }
    
}


//MARK: - Table View Configuration
extension MoodyHelpViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: register tableview delegates
    func configureTableView(){
        
        myTableView.delegate = self
        myTableView.dataSource = self
        configureTableCell()
    }
    
    
    //MARK: Configure Table cell
    private func configureTableCell(){
        myTableView.register(HelpTicketTableCell.nib, forCellReuseIdentifier: HelpTicketTableCell.identifier)
    }
    
    
    //MARK: Sets heigh of row of cell in table
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    //MARK: Detect cell tapped
    //. Selected tap index details are fetched
    //. opens customer support chat on basis of selected ticket
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let vc = CustomerSupport()
        if ticketHistory[indexPath.row]["_id"] as? String != nil {
            vc.ticket_id =  ticketHistory[indexPath.row]["_id"] as? String ?? ""
        } else {
            vc.ticket_id = ""
        }
        if ticketHistory[indexPath.row]["ticket_id"] as? String != nil {
            vc.ticketIdForChat =  ticketHistory[indexPath.row]["ticket_id"] as? String ?? ""
            if ticketHistory[indexPath.row]["status"] as? String == "open" {
                vc.status = true
            } else if ticketHistory[indexPath.row]["status"] as? String == "closed"{
                vc.status = false
            }
        } else {
            vc.ticketIdForChat = ""
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketHistory.count
    }
    
    
    //MARK: Each cell of table are set
    //. Each Cell details are fetched and fetched values are set to labels/buttons
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: HelpTicketTableCell.identifier) as! HelpTicketTableCell
        cell.selectionStyle = .none
        //Fetching Date of Query
        ticketHistory[indexPath.row]["start_at_date"] as? String != nil ? cell.dateLbl.text =  ticketHistory[indexPath.row]["start_at_date"] as? String ?? "" : addLabelTextAndSendWebHook(label: cell.dateLbl, name: "start_at_date")
       
        //Fetching Ticket ID of the query
        ticketHistory[indexPath.row]["ticket_id"] as? String != nil ? cell.ticketNumber.text =  ticketHistory[indexPath.row]["ticket_id"] as? String ?? "" : addLabelTextAndSendWebHook(label: cell.ticketNumber, name: "ticket_id")
        
        //Fetching Subject of Query
        ticketHistory[indexPath.row]["subject"] as? String != nil ? cell.messageTitle.text =  ticketHistory[indexPath.row]["subject"] as? String ?? "" : addLabelTextAndSendWebHook(label: cell.ticketNumber, name: "subject")
        
        //Fetching description of the query
        ticketHistory[indexPath.row]["last_message"] as? String != nil ? cell.messageDescription.text =  ticketHistory[indexPath.row]["last_message"] as? String ?? "" : addLabelTextAndSendWebHook(label: cell.messageDescription, name: "last_message")
        
        //Fetching the number of notifications of that specific thread
        ticketHistory[indexPath.row]["notification_count"] as? Int != nil ? cell.unreadMsgsTagLbl.text =  "\(ticketHistory[indexPath.row]["notification_count"] as! Int)" :  addLabelTextAndSendWebHook(label: cell.unreadMsgsTagLbl, name: "notification_count")
        print("Notification: \(String(describing: cell.unreadMsgsTagLbl.text))")

        if ticketHistory[indexPath.row]["notification_count"] as! Int > 0 {
            cell.unreadMsgsTagLbl.isHidden = false
        } else {
            cell.unreadMsgsTagLbl.isHidden = true
        }
                
        
        //Fetching status of the Query
        cell.statusButton.titleLabel?.text = ticketHistory[indexPath.row]["status"] as? String
        
        if ticketHistory[indexPath.row]["status"] as? String == "closed" {
            cell.statusButton.setTitle(NSLocalizedString("Closed", comment: ""), for: .normal)
            cell.statusButton.backgroundColor = UIColor.red
            cell.statusButton.setTitleColor(UIColor.white, for: .normal)
        }
        else if ticketHistory[indexPath.row]["status"] as? String == "open" {
            cell.statusButton.setTitle(NSLocalizedString("Open", comment: ""), for: .normal)
            cell.statusButton.backgroundColor = #colorLiteral(red: 1, green: 0.7529411765, blue: 0.262745098, alpha: 1)
            cell.statusButton.setTitleColor(UIColor.black, for: .normal)
            
        }
        
        return cell
    }
    
}




//MARK: - CollectionView for months
extension MoodyHelpViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: Month CollectionView is register
    func configureCollectionView(){
        
        myMonthCollectionView.delegate = self
        myMonthCollectionView.dataSource = self
    }
    
    
    //MARK: Number of items in MonthCollectionView are set here
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return months.count
    }
    
    //MARK: monthscollectionView name and color are set
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monthCollectionCell", for: indexPath) as! monthCollectionCell
        cell.monthLbl.attributedText = NSAttributedString(string: months[indexPath.row], attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12.0)])
        if indexPath.row == selectedMonth {
            cell.monthLbl.textColor = .black
        }else{
            cell.monthLbl.textColor = .lightGray
        }
        return cell
    }
    
    
    //MARK: Detects when user selects month in Collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        loaderUIUpdate(isAnimating: false)
        selectedMonth = indexPath.row
        var date:String = ""
        
        if(selectedMonth < 9){
            date = "\(Date().currentYear)-0\(selectedMonth + 1)"
            //printdate)
        }
        else{
            date = "\(Date().currentYear)-\(selectedMonth + 1)"
            //printdate)
        }
        setTicketHistoryDictionary(date: date)
        myMonthCollectionView.reloadData()
    }
    
}

//MARK: - API Calling
extension MoodyHelpViewController {
    
    
    //MARK: Ticket History Api call
    //. OnSuccess response is fetched and saved in global ticketHistory dict
    //. ShowTicketHistory is called to reloadTable view
    func helpApiCall(dictionary: [String:Any]){
        if(CheckInternet.Connection()){
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.ticketHistory, dictionary: dictionary, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Results) in

                print(Results)
                    switch Results{
                    case .success(let response):
                        print("Success in Ticket History API Call")
                        self.ticketHistory = (response["tickets"] as? [[String:Any]])!
                        print(response)
                        DispatchQueue.main.async { [self] in
                            self.myTableView.isUserInteractionEnabled = true
                            loaderUIUpdate(isAnimating: true)
                            showTicketHistory()
                        }
                    case .failure(let error):
                        print(error)
                        DispatchQueue.main.async { [self] in
                            self.myTableView.isUserInteractionEnabled = true
                            presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                            loaderUIUpdate(isAnimating: true)
                            showTicketHistory()
                        }
                    }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)
        }
    }
    
    //MARK: Check Ticket count and Reloads and Ticket TableView and CollectionView
    func showTicketHistory(){
        
        loaderUIUpdate(isAnimating: true)
        if ticketHistory.count <= 0 {
            NoHistoryLabel.isHidden = false
        }
        myMonthCollectionView.reloadData()
        myTableView.reloadData()
    }
    
    //MARK: Start and stop animating activity Loader.
    func loaderUIUpdate(isAnimating: Bool){
        
        NoHistoryLabel.isHidden = true
        loader.isHidden = isAnimating == true ? true : false
        isAnimating == true ? loader.stopAnimating() : loader.startAnimating()
        
    }
    
    //MARK: Updates ticket history
    //. Method is called when updateTicket emit is received
    //. Method receive data from emit and Ticket History is updated 
    @objc func updateTick(_ notification:NSNotification){
        
        let ticket = notification.userInfo as! [String:Any]
        for (index, _) in ticketHistory.reversed().enumerated() {
            if(ticket["_id"] as! String == ticketHistory[index]["_id"] as! String){
                ticketHistory[index]["notification_count"] = ticket["notification_count"] as! Int
                ticketHistory[index]["status"] = ticket["status"] as! String
                ticketHistory[index]["last_message"] = ticket["last_message"] as! String

            }
        }
        myTableView.reloadData()
    }

}
