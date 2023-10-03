//
//  NotificationAlert.swift
//  Moody_Posterv2.0
//
//  Created by   on 30/07/2021.
//

import Foundation
import UIKit

class NotificationAlert: UIViewController{
    
    @IBOutlet weak var backgroundView: UIView!
    
    
    //MARK: Calls when view is loaded
    //. Tap gesrture is added on exit
    override func viewDidLoad() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.exit))
        backgroundView.addGestureRecognizer(tap)
    }
    
    //MARK: - Dismiss Alert
    @objc func exit(sender : UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
}

