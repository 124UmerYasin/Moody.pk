//
//  NotificationViewController.swift
//  MoodyNotificationContent
//
//  Created by Umer yasin on 11/11/2021.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = "omar"
        
        let attachments = notification.request.content.attachments
        for attachment in attachments {
            if attachment.identifier == "picture"{
                print("imageurl : ",attachment.url)
                guard  let data = try? Data(contentsOf: attachment.url) else {
                    return
                }
                img.image = UIImage(data: data)
            }
        }
    }

}
