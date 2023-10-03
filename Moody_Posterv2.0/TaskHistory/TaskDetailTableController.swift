//
//  TaskDetailTableController.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit
import AVFoundation

class TaskDetailTableController: UITableViewController, AVAudioPlayerDelegate {
    
    
    @IBOutlet weak var taskerImage: UIImageView!
    @IBOutlet weak var taskerName: UILabel!
    @IBOutlet weak var stars: UILabel!
    @IBOutlet weak var timeAndDate: UILabel!
    @IBOutlet weak var taskType: UILabel!
    @IBOutlet weak var taskStatus: UILabel!
    @IBOutlet weak var DiscountLblView: UILabel!
    
    @IBOutlet weak var afterDiscountView: UILabel!
    @IBOutlet weak var taskId: UILabel!
    
    @IBOutlet weak var paymentType: UILabel!
    
    @IBOutlet weak var productAmount: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var totalTIme: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var moodyCharges: UILabel!
    @IBOutlet weak var totalAmountPaid: UILabel!
    @IBOutlet weak var discountAmount: UILabel!
    @IBOutlet weak var payableAmount: UILabel!
    
    @IBOutlet weak var productAmountLbl: UILabel!
    @IBOutlet weak var paymentTypeLbl: UILabel!
    @IBOutlet weak var copyImage: UIImageView!
    
    @IBOutlet weak var profileDetailView: UIView!
    @IBOutlet weak var taskIdView: UIView!
    @IBOutlet weak var receiptView: UIView!
    
    override func viewDidLoad() {
        addboarderandShadowAndRadius(view: profileDetailView)
        addboarderandShadowAndRadius(view: taskIdView)
        addboarderandShadowAndRadius(view: receiptView)
        taskerImage.layer.cornerRadius = 30
    }
    
    //MARK: Generic method to style views
    func addboarderandShadowAndRadius(view:UIView){
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: Code to copy reference code and save in clipboard 
    @IBAction func onClickCopy(_ sender: Any) {
        UIPasteboard.general.string = UserDefaults.standard.string(forKey: DefaultsKeys.referenceId)
        DispatchQueue.main.async {
            self.showToast(message: "Copied", font: .systemFont(ofSize: 17.0))
        }
    }
}
