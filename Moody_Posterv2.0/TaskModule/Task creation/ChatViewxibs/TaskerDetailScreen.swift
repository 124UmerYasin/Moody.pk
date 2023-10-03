//
//  TaskerDetailScreen.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 17/08/2021.
//

import Foundation
import UIKit
import MessageKit
import QuickLook
import SDWebImage

//content view for a custom cell loaded through a nib file
open class TaskerDetailScreen: MessageContentCell {
   
    var contentViewAttachment: UIView!
    var taskeName:UILabel!
    var vehicleNumber:UILabel!
    var rating:UILabel!
    var img:UIImageView!

    var fileManager : FileManager?
    var documentDir : NSString?
    var filePath : NSString?

    //MARK: return custom xib file view
    func getContentView() -> UIView{
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed("TaskerDetailsView", owner: self, options: nil)?.first as? UIView else {
            return UIView()
        }
        return contentView
    }
    
    //MARK: setup subviews
    open override func setupSubviews() {
        super.setupSubviews()
        contentViewAttachment = getContentView()
        img = contentViewAttachment.viewWithTag(22) as? UIImageView
        taskeName = contentViewAttachment.viewWithTag(1) as? UILabel
        rating = contentViewAttachment.viewWithTag(2) as? UILabel
        vehicleNumber = contentViewAttachment.viewWithTag(3) as? UILabel

        messageContainerView.addSubview(contentViewAttachment)
        
        if(UserDefaults.standard.string(forKey: DefaultsKeys.taskerNameDetail) != nil){
            taskeName.text = UserDefaults.standard.string(forKey: DefaultsKeys.taskerNameDetail)
        }else{
            taskeName.text = "Not Available"
        }
        
        if(UserDefaults.standard.string(forKey: DefaultsKeys.VehicleNumber) != ""){
            vehicleNumber.text = UserDefaults.standard.string(forKey: DefaultsKeys.VehicleNumber)
        }else{
            vehicleNumber.text = " "
        }
        
        if(UserDefaults.standard.double(forKey: DefaultsKeys.RatingOfTasker) != 0.0){
            rating.text = "\(UserDefaults.standard.double(forKey: DefaultsKeys.RatingOfTasker))"
        }else{
            rating.text = "0.0"
        }
        if(UserDefaults.standard.string(forKey: DefaultsKeys.taskerProfileImage) != nil && UserDefaults.standard.string(forKey: DefaultsKeys.taskerProfileImage) != ""){

            DispatchQueue.global().async {
                
            
            SDWebImageManager.shared.loadImage(with: URL(string: UserDefaults.standard.string(forKey: DefaultsKeys.taskerProfileImage)!), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                if error == nil{
                    if data != nil {
                        DispatchQueue.main.async {
                            self.img.image = UIImage(data: data!)
                        }
                    }else if image != nil{
                        DispatchQueue.main.async {
                            self.img.image = image
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.img.image = UIImage(named: "person2")
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.img.image = UIImage(named: "person2")
                    }
                }
                
            }
        }
        }else{
            self.img.image = UIImage(named: "person2")
        }
        
    }
 
    
    public override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        messageContainerView.backgroundColor = UIColor(named: "MessageBackgroundColor")
        setupSubviews()
       
    }
    
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        //print"UIOP")
    
    }
 
    //MARK: download image in local if found then show else download and save to local then show.
    func imageStorageAndSendMessage(localLink:String,imagePathLink:String){
        
        fileManager = FileManager.default
        let dirPaths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        documentDir = dirPaths[0] as? NSString
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url1 = NSURL(fileURLWithPath: path1)
        
        if let pathComponent1 = url1.appendingPathComponent(localLink) {
            let filePath1 = pathComponent1.path
            let fileManager1 = FileManager.default
            if fileManager1.fileExists(atPath: filePath1) {
                do{
                    let imgData = try! Data(contentsOf: URL(string: pathComponent1.absoluteString)!)
                    img.image = UIImage(data: imgData)
                }
            } else {
                let link = URL(string: imagePathLink)
                guard let data = try? Data(contentsOf: link!) else{
                    self.img.image = UIImage(named: "person2")
                    return
                }
                saveImageToLocalStorage(localPath: localLink, base64Data: data)
                img.image = UIImage(data: data)
                
            }
        } else {
            //print("FILE PATH NOT AVAILABLE")
        }
    }
    //MARK: Save  image File to Local Storage
    func saveImageToLocalStorage(localPath:String,base64Data:Data){
        
        self.filePath=documentDir?.appendingPathComponent(localPath) as NSString?
        self.fileManager?.createFile(atPath: filePath! as String, contents: nil, attributes: nil)
        let decodedData = base64Data
        let content: Data = decodedData
        let fileContent: Data = content
        try? fileContent.write(to: URL(fileURLWithPath: documentDir!.appendingPathComponent(localPath)), options: [.atomicWrite])
        
        
    }
    
}

