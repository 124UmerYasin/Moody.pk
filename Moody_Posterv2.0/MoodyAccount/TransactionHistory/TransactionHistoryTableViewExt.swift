//
//  TransactionHistoryTableViewExt.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 05/06/2021.
//

import Foundation
import UIKit

extension TransactionHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Returning transactions count in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionHistory.count
    }
    
    //MARK: Setting cells in transaction history table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryCell", for: indexPath) as! TransactionHistoryCell
        let rs = NSLocalizedString("Rs:", comment: "")
        transactionHistory[indexPath.row]["amount"] as? Int != nil ? cell.fareLabel.text =  "\(rs) \(String(describing: transactionHistory[indexPath.row]["amount"] as? Int ?? 0 ) )" : addTextAndSendWebHook(label: cell.fareLabel, name: "amount")
        
        
        settingCellColours(transactions : transactionHistory[indexPath.row], cell : cell)
        transactionHistory[indexPath.row]["transaction_date"] as? String != nil ? cell.dateLabel.text = transactionHistory[indexPath.row]["transaction_date"] as? String ?? "-" : addTextAndSendWebHook(label: cell.dateLabel, name: "transaction_date")
        
        transactionHistory[indexPath.row]["transaction_time"] as? String != nil ? cell.timeLabel.text = transactionHistory[indexPath.row]["transaction_time"] as? String ?? "-" : addTextAndSendWebHook(label: cell.timeLabel, name: "transaction_time")
        
        
        let paymentType = typeCheck(taskType: transactionHistory[indexPath.row]["payment_method"] as! String)
        transactionHistory[indexPath.row]["payment_method"] as? String != nil ? cell.paymentMethodLable.text = "via \(paymentType)" : addTextAndSendWebHook(label: cell.paymentMethodLable, name: "payment_method")
        
        return cell
    }
    
    func addTextAndSendWebHook(label:UILabel,name:String){
        label.text = "-"
        whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.viewTransactionsHistory, Key: "\(name)")
    }
    
    func addTextAndSendWebHook(name:String){
        whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.viewTransactionsHistory, Key: "\(name)")
    }
    

    
    
    
    //MARK: Setting colours for labels in cells according to the status of transaction
    func settingCellColours(transactions : [String:Any], cell : TransactionHistoryCell){
        
        cell.sendBtn.backgroundColor = UIColor.white
        
        if(transactions["status"] as? String != nil ){
            if((transactions["status"] as? String ?? "") == "completed"){
                
                if((transactions["type"] as? String ?? "") == "task_fare"){
                    
                    let type = NSLocalizedString("Task Fare", comment: "")
                    cell.sendBtn.setTitle(type, for: .normal)
                    cell.sendBtn.setTitleColor( UIColor(named: "completedText"), for: .normal)
                    cell.sendBtn.backgroundColor = UIColor(named: "completedBackground")
                    
                }else if((transactions["type"] as? String ?? "") == "deposit"){
                    
                    let type = NSLocalizedString("Deposit", comment: "")
                    cell.sendBtn.setTitle(type, for: .normal)
                    cell.sendBtn.setTitleColor( UIColor(named: "completedText"), for: .normal)
                    cell.sendBtn.backgroundColor = UIColor(named: "completedBackground")
                    
                }else if((transactions["type"] as? String ?? "") == "promocode"){
                    
                    let type = NSLocalizedString("Promo Code", comment: "")
                    cell.sendBtn.setTitle(type, for: .normal)
                    cell.sendBtn.setTitleColor( UIColor(named: "completedText"), for: .normal)
                    cell.sendBtn.backgroundColor = UIColor(named: "completedBackground")
                    
                }else {
                    
                    let taskType = typeCheck(taskType: transactions["type"] as! String)
                    cell.sendBtn.setTitle(taskType, for: .normal)
                    cell.sendBtn.setTitleColor( UIColor(named: "completedText"), for: .normal)
                    cell.sendBtn.backgroundColor = UIColor(named: "completedBackground")
                }
                
            }else if ((transactions["status"] as? String ?? "") == "declined"){
                
                cell.sendBtn.setTitle(NSLocalizedString("Declined", comment: ""), for: .normal)
                cell.sendBtn.setTitleColor(UIColor(named: "cancelLabel"), for: .normal)
                cell.sendBtn.backgroundColor = UIColor(named: "cancelLabelBg")
                
            }else{
                cell.sendBtn.setTitle(NSLocalizedString("Pending", comment: ""), for: .normal)
                cell.sendBtn.setTitleColor( UIColor(named: "AccentColor"), for: .normal)
                cell.sendBtn.backgroundColor = UIColor(named: "Pending")
            }
        }else{
            let taskType = typeCheck(taskType: transactions["type"] as! String)
            cell.sendBtn.setTitle(taskType, for: .normal)
            cell.sendBtn.setTitleColor( UIColor(named: "completedText"), for: .normal)
            cell.sendBtn.backgroundColor = UIColor(named: "completedBackground")
            whistleWebhook.sharedInstance.FoundNillWebhooks(Endpoint: ENDPOINTS.viewTransactionsHistory, Key: "status")
        }
    }
    
    
    
    //MARK: Setting height for each row in table
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    //MARK: Checks task type and remove - with space
    func typeCheck(taskType:String) -> String{
        
        let type = taskType
        let newString = type.replacingOccurrences(of: "_", with: " ")
        
        return newString
    }
    
    
}
