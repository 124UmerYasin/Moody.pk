//
//  NotificationService.swift
//  MoodyNotificationService
//
//  Created by Umer yasin on 11/11/2021.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title)"
            bestAttemptContent.body = "\(bestAttemptContent.userInfo["body"] ?? "")"
            guard let attachmentUrlString = bestAttemptContent.userInfo["image"] as? String,
                  let attachmentURL = URL(string: attachmentUrlString) else{
                return
            }
            
            downloadImageFrom(url: attachmentURL) { attachment in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                    contentHandler(bestAttemptContent)
                }
            }
            
            
        }
    }
    
    private func downloadImageFrom(url:URL,with completionHandler: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (downloadedUrl,response,error) in
            guard let downloadedUrl = downloadedUrl else{
                completionHandler(nil)
                return
            }
            var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())
            let uniqueURLEnding = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            urlPath = urlPath.appendingPathComponent(uniqueURLEnding)
            
            try? FileManager.default.moveItem(at: downloadedUrl, to: urlPath)
            do{
                let attachment = try UNNotificationAttachment(identifier: "picture", url: urlPath, options: nil)
                completionHandler(attachment)
            }catch{
                completionHandler(nil)
            }
            
        }
        task.resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
