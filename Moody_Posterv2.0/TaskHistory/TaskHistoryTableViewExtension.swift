//
//  TaskHistoryTableViewExtension.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit

extension TaskHistoryViewController: UITableViewDelegate, UITableViewDataSource{
     
    //MARK: Setitng number of sections in table view depending upon number of task in taskHistory Array fetched from api
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasksHistory.count
        
    }
    //MARK: Sets Section Number in Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //MARK: Sets view of header in section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    //MARK: Sets height of header in section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(24)
    }
    
    //MARK: Sets height of each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(160)
    }
    
    
    
    //MARK: Each row data is set
    //. Each Cell details are fetched and fetched values are set to labels/buttons
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskHistoryCell", for: indexPath) as! TaskHistoryCell
        
        cell.selectedMonth = selectedMonth
        
        cell.playButtonTapped = {
            for tempCell in tableView.visibleCells{
                if let ultraTempCell = tempCell as? TaskHistoryCell, ultraTempCell != cell /* or something like this */{
                    ultraTempCell.audioSeekBar.progress = 0.0
                    ultraTempCell.timer?.invalidate()
                    ultraTempCell.audioPlayer?.pause()
                    let image = UIImage(named: "audioPlay")?.withRenderingMode(.alwaysTemplate)
                    ultraTempCell.audioPlayPauseBtn.setImage(image, for: .normal)
                    ultraTempCell.audioPlayPauseBtn.tintColor = UIColor.black
                    ultraTempCell.isPlaying = false
                    ultraTempCell.audioTime.text = "00:00"

                }
            }
        }
        
        cell.navigationController = self.navigationController
        cell.taskDetails = tasksHistory[indexPath.first!]
        tasksHistory[indexPath.first!]["start_at_date"] as? String != nil ? cell.Date.text =  tasksHistory[indexPath.first!]["start_at_date"] as? String ?? "" : addLabelTextAndSendWebHook(label: cell.Date, name: "tasker_name")
        
        tasksHistory[indexPath.first!]["status"] as? String != nil ? cell.statusBtn.setTitle("\(tasksHistory[indexPath.first!]["status"] as? String ?? "")", for: .normal) : addLabelTextAndSendWebHook(label: nil, name: "status")
        
        
        cell.status = (tasksHistory[indexPath.first!]["status"] as? String)!
        
        tasksHistory[indexPath.first!]["_id"] as? String != nil ? cell.taskID = tasksHistory[indexPath.first!]["_id"] as? String ?? "" : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "_id")
        
        tasksHistory[indexPath.first!]["type"] as? String != nil ? cell.taskType = tasksHistory[indexPath.first!]["type"] as? String ?? "" : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "type")
        
        if(tasksHistory[indexPath.first!]["type"] as? String == "top_up"){
            cell.audioPlayPauseBtn.isHidden = true
            cell.audioTime.isHidden = true
            cell.audioSeekBar.isHidden = true
            cell.topUpTaskLbl.isHidden = false
        }else{
            cell.audioPlayPauseBtn.isHidden = false
            cell.audioTime.isHidden = false
            cell.audioSeekBar.isHidden = false
            cell.topUpTaskLbl.isHidden = true
        }
        
        cell.taskType = (tasksHistory[indexPath.first!]["type"] as? String)!
        
        cell.taskTypeLabel.text = cell.taskType != "" ? setTypeLabel(taskType: cell.taskType) : "-"
        cell.taskTypeImage.image = cell.taskType != "" ? UIImage(named: setImageView(taskType: cell.taskType)) : UIImage(named: "pickAndDrop")
    
        let fareDetails: [String:Any] = tasksHistory[indexPath.first!]["fare_details"] as! [String : Any]
        var discount:String = ""
        fareDetails["discount"] as? String != nil ? discount = fareDetails["discount"] as? String ?? "0%" : whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "discount")
        cell.discount = discount
        let rs = NSLocalizedString("Rs:", comment: "")

        if discount == "0%"{

            if(fareDetails["total_fare"] as? Int != nil){
                cell.Fare.text = ("\(rs) \(fareDetails["total_fare"] as? Int ?? 0)")
            }else{
                whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "total_fare")
                cell.Fare.text = "\(rs) 0"
            }
            
        }else{
            if(fareDetails["total_fare_after_discount"] as? Int != nil){
                cell.Fare.text = ("\(rs) \(fareDetails["total_fare_after_discount"] as? Int ?? 0)")
            }else{
                whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "total_fare_after_discount")
                cell.Fare.text = "\(rs) 0"
            }
        }
        
        if(tasksHistory[indexPath.first!]["status"] as? String != "completed" && tasksHistory[indexPath.first!]["status"] as? String != "cancelled" && tasksHistory[indexPath.first!]["status"] as? String != "due_payment"){
            
            cell.statusBtn.setTitle(NSLocalizedString("Active", comment: ""), for: .normal)
            cell.Fare.text = ("\(rs) \(tasksHistory[indexPath.first!]["run_time_fare"] as? String ?? "0")")
            
        }
        else if(tasksHistory[indexPath.first!]["status"] as? String == "completed" || tasksHistory[indexPath.first!]["status"] as? String == "due_payment"){
            cell.statusBtn.setTitle(NSLocalizedString("Completed", comment: ""), for: .normal)
        }else if(tasksHistory[indexPath.first!]["status"] as? String == "cancelled"){
            cell.statusBtn.setTitle(NSLocalizedString("Cancelled", comment: ""), for: .normal)
        }
        
        
        if(tasksHistory[indexPath.first!]["attachment_path"] as? String != nil){
            cell.audioPath = (tasksHistory[indexPath.first!]["attachment_path"] as? String)!
        
            if !(cell.isPlaying){
                cell.audioTime.text = "00:00"
                let image = UIImage(named: "audioPlay")?.withRenderingMode(.alwaysTemplate)
                cell.audioPlayPauseBtn.setImage(image, for: .normal)
                cell.audioPlayPauseBtn.tintColor = UIColor.black
                
            }
        }
        
        if(tasksHistory[indexPath.first!]["poster_notification_count"] as? Int ?? 0 > 0){
            let count = tasksHistory[indexPath.first!]["poster_notification_count"]!
            cell.countLbl.text = "\(count)"
            cell.notificationImage.isHidden = false
            cell.countLbl.isHidden = false
            
       }
        else{
            cell.notificationImage.isHidden = true
            cell.countLbl.isHidden = true
        }
        
        if(tasksHistory[indexPath.first!]["status"] as? String != nil){
            
            if(tasksHistory[indexPath.first!]["status"] as! String == "completed" || tasksHistory[indexPath.first!]["status"] as! String == "due_payment"){
                cell.statusBtn.setTitleColor(UIColor(named: "completedLabel"), for: .normal)
                cell.statusBtn.backgroundColor = UIColor(named: "completedLabelBg")
            }else if(tasksHistory[indexPath.first!]["status"] as! String == "cancelled"){
                cell.statusBtn.setTitleColor(UIColor(named: "cancelLabel"), for: .normal)
                cell.statusBtn.backgroundColor = UIColor(named: "cancelLabelBg")
            }else{
                cell.statusBtn.setTitleColor(UIColor(named: "statusButtonText"), for: .normal)
                cell.statusBtn.backgroundColor = UIColor(named: "statusButtonBack")
                cell.statusBtn.layer.cornerRadius = 5
            }
            
        }else{
            whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "total_fare_after_discount")
            cell.statusBtn.setTitleColor(UIColor(named: "cancelLabel"), for: .normal)
            cell.statusBtn.backgroundColor = UIColor(named: "cancelLabelBg")
        }
        
        
        return cell
    }
    

    //MARK: Sets task type to Label
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
    
    
    //MARK: Image is set on basis task type
    func setImageView(taskType: String) -> String{
        
        var image:String = ""
        
        switch taskType {
        case "cash_delivery":
            image = "topUpImg"
            break
        case "ride_hailing":
            image = "rideSharingImg"
            break
        case "pick_and_drop":
            image = "pickAndDrop"
            break
        case "buy_and_drop":
            image = "BuyAndDeliver"
            break
        case "top_up":
            image = "topUpImg"
            break
        case "window_shopping":
            image = "windowShopping"
            break
        default:
            image = "pickAndDrop"
            break
        }
        
        return image
        
    }
    
    //MARK: Sends Webhook of readTaskHistory api
    func addLabelTextAndSendWebHook(label:UILabel? = nil ,name:String){
        if(label != nil){
            label!.text = ""
        }
        whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.readTaskHistory, Key: "\(name)")
    }
    
    //MARK: Setting tableview cell style
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
}
