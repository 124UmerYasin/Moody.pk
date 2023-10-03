//
//  TaskDetailsViewController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit
import AVFoundation
import SDWebImage

class TaskDetailViewController: UIViewController, UITableViewDelegate{
    
    
    //MARK: Outlets
    @IBOutlet var viewTaskMapBtn: UIButton!
    @IBOutlet var Loader: UIActivityIndicatorView!
    @IBOutlet weak var viewChatButton: UIButton!
    
    
    //MARK: Variables
    var taskID:String = ""
    var TaskDetailTable: TaskDetailTableController!
    var tableView: UITableView!
    var taskDetails = [String:Any]()
    var taskType:String = ""
    var selectedMonth: Int = 0
    
    var fileManager : FileManager?
    var documentDir : NSString?
    var filePath : NSString?
    var discount: String?
    
    static var seeTaskMap: Bool = true
    
    //MARK: calls when first time View Loads
    //. Registers Notification Observers
    //. Task details fetch
    //. Ui views setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotifications()
        getTaskDetails()
        tableView.delegate = self
        tableView.separatorStyle = .none
        setupNavigationBar()
        navigationController?.isNavigationBarHidden = false
        addLayoutToButton()
        DefaultsKeys.historyYearCheck = true
    }
    
  
    //MARK: Calls just before view appears
    //. sets MapBtn
    //. Navigagtion title is set
    //. BottomTabBar hidden
    override func viewWillAppear(_ animated: Bool) {
        setMapBtn()
        self.navigationItem.title = NSLocalizedString("Task Details", comment: "")
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: Calls just after view disappears
    //. sets last selected month in history
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.setValue(selectedMonth, forKey: DefaultsKeys.selectedHistoryMonth)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        TaskDetailTable = (segue.destination as! UITableViewController) as? TaskDetailTableController
        tableView = TaskDetailTable.tableView
    }
    
    //MARK: MapBtn colot interaction is set on bool check (if coordinates of task are available) 
    func setMapBtn(){
        if !TaskDetailViewController.seeTaskMap {
            viewTaskMapBtn.isEnabled = false
            viewTaskMapBtn.backgroundColor =  UIColor(named: "DullGreen")
        }else{
            viewTaskMapBtn.isUserInteractionEnabled = true
            viewTaskMapBtn.isEnabled = true
            viewTaskMapBtn.backgroundColor =  UIColor(named: "AccentColor")
        }
    }
    
    //MARK: Register Notifcation Observer
    func registerNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.internetRunning(_:)), name: NSNotification.Name(rawValue: "checkInternetConnectionOnline"), object: nil)
    }
    
    //MARK: Styling to viewChat Button
    func addLayoutToButton(){
        viewChatButton.backgroundColor = .white
        viewChatButton.layer.borderColor = UIColor.black.cgColor
        viewChatButton.layer.borderWidth = 2
    }
    
    
    //MARK: Check internet is running or not and make chages according to that
    @objc func internetRunning(_ notification: NSNotification) {
        
        DispatchQueue.main.async { [self] in
            getTaskDetails()
        }
    }

    

    
    
    //MARK: Opens complete task Map
    //. Tasker coordinates are set to maps static variable to task path path
    //. Naviagted to TaskMapViewController
    @IBAction func seeTaskMapBtn(_ sender: Any) {
        
        viewTaskMapBtn.isUserInteractionEnabled = false
        let storyboardD = UIStoryboard(name: "TaskHistory", bundle: nil)
        let controller = storyboardD.instantiateViewController(withIdentifier: "TaskMapViewController")
        
        if(taskDetails["pickup_location"] as? String != nil && taskDetails["pickup_location"] as? String != ""){
            let pickupCoord = taskDetails["pickup_location"] as? String ?? "0.0, 0.0"
            
            let coordinates = pickupCoord.split(separator: ",")
            let initialLat = Double(coordinates[0])!
            let initialLong = Double(coordinates[1].split(separator: " ")[0])!
            let pickuplocation:[Double] = [initialLat, initialLong]
            
            TaskMapViewController.coordinates = taskDetails["location_logs"] as! [String]
            TaskMapViewController.pickupCoordinates = pickuplocation
            if(TaskMapViewController.coordinates.count > 0){
                controller.modalPresentationStyle = .fullScreen
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.title = ""
                self.navigationController?.pushViewController(controller, animated: true)
            }else{
                presentAlert(title: "Maps not available", message: "Unfortunately, maps are not available for this task.", parentController: self)
            }
        }else{
            presentAlert(title: "Maps not available", message: "Unfortunately, maps are not available for this task.", parentController: self)
            
        }
        
        
        
    }
    
    //MARK: TaskDetails Api Call
    //. Dict is prepared for viewTaskHistoryDetail api
    //. On Api Success task details are set
    //. Ui changes
    func getTaskDetails(){
        viewChatButton.isUserInteractionEnabled = false
        if(CheckInternet.Connection()){
            var dictionary = [String:Any]()
            dictionary["task_id"] = self.taskID
            dictionary["user_agent"] = AppPermission.getDeviceInfo()
            dictionary["platform"] = "ios"
            
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.viewTaskHistoryDetail, dictionary: dictionary, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Results) in
                
                switch Results{
                case .success(let response):
                    taskDetails = response["task"] as! [String : Any]
                    DispatchQueue.main.async {
                        
                        setTaskDetails(taskDetails: taskDetails)
                        loaderUIUpdate(isAnimating: true)
                        
                        viewTaskMapBtn.isUserInteractionEnabled = true
                        viewChatButton.isUserInteractionEnabled = true
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( error.title, comment: ""), parentController: self)
                        loaderUIUpdate(isAnimating: true)
                    }
                }
            }
        }else{
            self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString( "No Internet Connection. Please Try again later when internet is available", comment: ""), parentController: self)
            
        }
        
        
    }
    
    //MARK: TaskDetails are set to labels
    //. Method receive taskDetails object
    //. Data is fetched and sets to label
    //. Fare Details are fetched and shown on task receiept
    func setTaskDetails(taskDetails: [String:Any]){
        
        taskDetails["tasker_name"] as? String != nil ? TaskDetailTable.taskerName.text = taskDetails["tasker_name"] as? String ?? "" : addLabelTextAndSendWebHook(label: TaskDetailTable.taskerName, name: "tasker_name")
        taskDetails["start_at_date"] as? String != nil ? TaskDetailTable.timeAndDate.text = taskDetails["start_at_date"] as? String ?? "" : addLabelTextAndSendWebHook(label: TaskDetailTable.timeAndDate, name: "start_at_date")
        
        if(taskDetails["status"] as? String != nil){
            
            if(taskDetails["status"] as! String == "completed"){
                TaskDetailTable.taskStatus.textColor = UIColor(named: "completedLabel")
                TaskDetailTable.taskStatus.backgroundColor = UIColor(named: "completedLabelBg")
                TaskDetailTable.taskStatus.layer.cornerRadius = 5
            }else if(taskDetails["status"] as! String == "cancelled"){
                TaskDetailTable.taskStatus.textColor = UIColor(named: "cancelLabel")
                TaskDetailTable.taskStatus.backgroundColor = UIColor(named: "cancelLabelBg")
                TaskDetailTable.taskStatus.layer.cornerRadius = 5
            }else{
                
                TaskDetailTable.taskStatus.textColor = UIColor(named: "statusButtonText")
                TaskDetailTable.taskStatus.backgroundColor = UIColor(named: "statusButtonBack")
                TaskDetailTable.taskStatus.layer.cornerRadius = 5
            }
            
            var task_Status = taskDetails["status"] as? String ?? ""
            task_Status =  task_Status.capitalized
            
            taskDetails["status"] as? String != nil ? TaskDetailTable.taskStatus.text? = NSLocalizedString(task_Status, comment: "") : addLabelTextAndSendWebHook(label: TaskDetailTable.taskStatus, name: "status")
            
        }
        
        let taskType = taskDetails["type"] as? String ?? ""
        
        let type = setTypeLabel(taskType: taskType)
        
        taskDetails["type"] as? String != nil ? TaskDetailTable.taskType.text = type : addLabelTextAndSendWebHook(label: TaskDetailTable.taskType, name: "type")
        taskDetails["start_at_time"] as? String != nil ? TaskDetailTable.startTime.text = taskDetails["start_at_time"] as? String ?? "" : addLabelTextAndSendWebHook(label: TaskDetailTable.startTime, name: "start_at_time")
        taskDetails["end_at_time"] as? String != nil ? TaskDetailTable.endTime.text = taskDetails["end_at_time"] as? String ?? "" : addLabelTextAndSendWebHook(label: TaskDetailTable.endTime, name: "end_at_time")
        
        taskDetails["reference_id"] as? String != nil ? TaskDetailTable.taskId.text = taskDetails["reference_id"] as? String ?? "" : addLabelTextAndSendWebHook(label: TaskDetailTable.taskId, name: "reference_id")
        
        let locations = taskDetails["location_logs"] as! [Any]
        if locations.count > 1 {
            TaskDetailViewController.seeTaskMap = true
            viewTaskMapBtn.isEnabled = true
            viewTaskMapBtn.backgroundColor =  UIColor(named: "AccentColor")
        }else{
            TaskDetailViewController.seeTaskMap = false
            viewTaskMapBtn.isEnabled = false
            viewTaskMapBtn.backgroundColor =  UIColor(named: "DullGreen")
            
        }
        
        if(taskDetails["reference_id"] as? String == ""){
            TaskDetailTable.taskId.text = "N/A"
        }else{
            UserDefaults.standard.setValue(taskDetails["reference_id"], forKey: DefaultsKeys.referenceId)
            
        }
        
        
        var fareDetails = [String:Any]()
        if(taskDetails["fare_details"] as? [String : Any] != nil){
            fareDetails = taskDetails["fare_details"] as! [String : Any]
        }else{
            whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.viewTaskHistoryDetail, Key: "fare_details")
        }
        fareDetails["moody_charges"] as? Int != nil ? TaskDetailTable.moodyCharges.text = "Rs \(fareDetails["moody_charges"] as? Int ?? 0)" : addLabelTextAndSendWebHook(label: TaskDetailTable.moodyCharges, name: "moody_charges")
        fareDetails["total_fare"] as? Int != nil ? TaskDetailTable.totalAmountPaid.text = ("Rs \(fareDetails["total_fare"] as? Int ?? 0)") : addLabelTextAndSendWebHook(label: TaskDetailTable.totalAmountPaid, name: "total_fare")
        fareDetails["total_time_taken"] as? String != nil ?  TaskDetailTable.totalTIme.text = ("\(fareDetails["total_time_taken"] as? String ?? "-")") : addLabelTextAndSendWebHook(label: TaskDetailTable.totalTIme, name: "total_time_taken")
        fareDetails["total_distance"] as? Double != nil ? TaskDetailTable.totalDistance.text = ("\(fareDetails["total_distance"] as? Double ?? 0.0) Km") : addLabelTextAndSendWebHook(label: TaskDetailTable.totalDistance, name: "total_distance")
        
        if(fareDetails["payment_method"] as? String != nil){
            
            fareDetails["payment_method"] as? String != nil ? TaskDetailTable.paymentType.text = ("\(fareDetails["payment_method"] as? String ?? "")") : addLabelTextAndSendWebHook(label: TaskDetailTable.paymentTypeLbl, name: "payment_method")
            
            TaskDetailTable.paymentTypeLbl.isHidden = false
            TaskDetailTable.paymentType.isHidden = false
            
        }
        
        if(fareDetails["product_price"] as? Int != 0){
            TaskDetailTable.productAmountLbl.isHidden = false
            TaskDetailTable.productAmount.isHidden = false
            
            fareDetails["product_price"] as? Int != 0 ? TaskDetailTable.productAmount.text = ("\(fareDetails["product_price"] as? Int ?? 0)") : addLabelTextAndSendWebHook(label: TaskDetailTable.productAmountLbl, name: "product_price")
            
           
        }
        
        
        if((fareDetails["total_fare_after_discount"] as? Int ?? 0) != (fareDetails["total_fare"] as? Int ?? 0)){
            
            if fareDetails["discount"] != nil {
    
                TaskDetailTable.DiscountLblView.isHidden = false
                TaskDetailTable.discountAmount.isHidden = false
                TaskDetailTable.afterDiscountView.isHidden = false
                TaskDetailTable.payableAmount.isHidden = false
                
                
                fareDetails["discount"] as? String != nil ? TaskDetailTable.discountAmount.text = ("\(fareDetails["discount"] as? String ?? "")") : addLabelTextAndSendWebHook(label: TaskDetailTable.totalDistance, name: "discount")
                
                fareDetails["total_fare_after_discount"] as? Int != nil ? TaskDetailTable.payableAmount.text = ("Rs \(fareDetails["total_fare_after_discount"] as? Int ?? 0)") : addLabelTextAndSendWebHook(label: TaskDetailTable.payableAmount, name: "total_fare_after_discount")
            }
            
        }
    
        var stars:Int = 0
        if(taskDetails["tasker_rating"] as? Float != nil){
            stars = taskDetails["tasker_rating"] as? Int ?? 0
            TaskDetailTable.stars.text = String(stars)
        }else{
            stars = 0
            whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.viewTaskHistoryDetail, Key: "tasker_rating")
            TaskDetailTable.stars.text = String(stars)
        }
        TaskDetailTable.stars.attributedText = NSMutableAttributedString().starWithRating(rating: Float(stars), outOfTotal: 5, withFontSize: 40)
        
        let imgLink = taskDetails["tasker_profile_picture"] as? String ?? ""
        if(imgLink != ""){
            SDWebImageManager.shared.loadImage(with: URL(string: imgLink), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                if error == nil{
                    DispatchQueue.main.async {
                        self.TaskDetailTable.taskerImage.image = UIImage(data: data!)
                    }
                }
            }
        }
        
        
    }
    
    
    //MARK: sets Type of Task
    func setTypeLabel(taskType: String) -> String{
        
        var type:String = ""
        var taskTypeReplacement = taskType
        if(taskType.count > 0){
            taskTypeReplacement = taskTypeReplacement.replacingOccurrences(of: "_", with: " ")
            taskTypeReplacement =  taskTypeReplacement.capitalized
        }
        
        switch taskType {
        case "cash_delivery":
            type = "Cash Delivery"
            break
        case "ride_hailing":
            type = NSLocalizedString("Ride Sharing", comment: "")
            break
        case "pick_and_drop":
            type = NSLocalizedString("Pick & Deliver", comment: "")
            break
        case "buy_and_drop":
            type = NSLocalizedString("Buy & Deliver", comment: "")
            break
        case "top_up":
            type = NSLocalizedString("Top up", comment: "")
            break
        case "window_shopping":
            type = NSLocalizedString("Window Shopping", comment: "")
            break
        default:
            type = taskTypeReplacement
            break
        }
        
        return type
        
    }
    
    //MARK: Method to send Webhook
    func addLabelTextAndSendWebHook(label:UILabel,name:String){
        label.text = ""
        whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.viewTaskHistoryDetail, Key: "\(name)")
    }
    
    //MARK: Calls when table will display. Sets Styling for cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTransparent(color: .white)
    }
    
    //MARK: Sets Height of header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(10)
    }
    
    //MARK: sets height of rows of each section in table
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180
        }else  if indexPath.section == 1 {
            return 40
        }
        else  if indexPath.section == 2 {
            return 350
        }
        return CGFloat()
    }
    
    //MARK: Sets Background color to header view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    //MARK: Start and stop animating activity Loader.
    func loaderUIUpdate(isAnimating: Bool){
        
        Loader.isHidden = isAnimating == true ? true : false
        isAnimating == true ? Loader.stopAnimating() : Loader.startAnimating()
        
    }
    
    //MARK: Navigates to Task Chat History
    @IBAction func onClickViewChat(_ sender: Any) {
        
        DispatchQueue.main.async { [self] in
            viewChatButton.isUserInteractionEnabled = false
            UserDefaults.standard.setValue(taskID, forKey: DefaultsKeys.taskId)
            ChatViewController.isFromActiveTask = false
            //ChatViewController.istaskfinisherOrNot = true
            let vc = ExtendedChat()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            viewChatButton.isUserInteractionEnabled = true
        }
        
        
    }
}
