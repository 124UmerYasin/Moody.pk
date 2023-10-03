//
//  ImageAndCameraFunctionality.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 05/06/2021.
//

import Foundation
import MessageKit
import UIKit
import AVKit
import YPImagePicker
import CoreLocation


extension ChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: configure image type message before sending it
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard
            let msg = message as? Messgae,
            let url = URL(string: msg.downloadURL)
        else { return }
        imageView.load(url: url)
    }
    
    //MARK: action sheet presented when camera button is tapped
    func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: NSLocalizedString( "Attach Media", comment: ""),
                                            message: NSLocalizedString("What would you like to attach?", comment: ""),
                                            preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor(named: "ButtonColor")
        addactionToActionSheet(actionSheet: actionSheet)
        toShowpopoverOnIpad(actionSheet: actionSheet)
        cameraButton.isUserInteractionEnabled = true
        present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: add action to actionsheet
    func addactionToActionSheet(actionSheet:UIAlertController){
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default, handler: { [weak self] _ in
            ChatViewController.isFromGallery = true
            self?.photoLibrary(imageType: .photoLibrary)
            
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default, handler: { [weak self]  _ in
            ChatViewController.isFromGallery = true
            self?.photoLibrary(imageType: .camera)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
    }
    
    //MARK: to show popover on ipad
    func toShowpopoverOnIpad(actionSheet:UIAlertController){
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.maxX/2 ,y: self.view.frame.maxY ,width: 0 ,height: 0);
        actionSheet.popoverPresentationController?.permittedArrowDirections = []
    }
    
    //MARK: configure photoLibraray
    //. sets Configuration for Gallery image
    func configurePhotoLibrary() -> YPImagePickerConfiguration{
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 5
        config.screens = [.library]
        config.library.mediaType = .photo
        config.showsCrop = .none
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = false
        config.library.isSquareByDefault = false
        //config.library.defaultMultipleSelection = true
        config.library.skipSelectionsGallery = false
        config.library.options = nil
        config.library.preselectedItems = nil
        config.showsVideoTrimmer = true
        config.video.compression = AVAssetExportPresetLowQuality
        
        return config
    }
    
    //MARK: Save Images adn videos in Array to send to api
    func saveMediaInArray(meadiaArray:[YPMediaItem]){
        for pics in meadiaArray{
            switch pics{
            case .photo(p: let p):
                imgAndVideoData.append(p.image.jpegData(compressionQuality: 0.0)!)
            case .video(v: let v):
                let temp = v.url.absoluteURL
                do{
                    let dta = try Data(contentsOf: temp)
                    imgAndVideoData.append(dta)
                }catch{
                    //print"cannot insert decoded image from url in image and videos array found an error while doing this.")
                }
            }
        }
    }
    
    //MARK: when image selected from gallery
    func sendImage(imageBase64:Data,index:Int,taskId:String){
        //if internet is avalianble add images locally and maintain its data and state
        //if index is not zero add image in chat and get its index then call api after 200 response of api that saved index is releaded and change message
        //state from sending to sent.
        // if api faliure add locally and retry after internet connection becomes stable or comes in chat view
        var indexqw = index
            if(index != 0){
                indexqw = index
            }else{
                indexqw = addImageInChats(imagData: imageBase64)
        }
        if CheckInternet.Connection() {
            ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.send_message, dictionary: createSendImageDictionary(imageBase64: imageBase64,taskId:taskId), httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Result) in
            switch Result {
            case .success(let response):
                //saveImageToLocalStorage(localPath: "\(response["message_id"] as! String).png", base64Data: imageBase64)
                if(ChatViewController.isScreenVisible && UserDefaults.standard.string(forKey: DefaultsKeys.taskId) == taskId){
                    addImageinChat(messageId: response["message_id"] as! String, role: "is_poster", imagData: imageBase64, index: indexqw,is_notified: false,time: "\(response["message_time"] as! String)", title: "", resp: response)
                }
               
                break
            case .failure(_):
                addMessageLocally(message: imageBase64.base64EncodedString(), type: "image", index: indexqw, localImage: imageBase64, location: "")
                break
            }
        }
        }else{
            addMessageLocally(message: imageBase64.base64EncodedString(), type: "image", index: indexqw, localImage: imageBase64, location: "")
        }
        
    }
    
    //MARK:Appends image Message in chat
    //. Receives image Data
    //. Returns index of message in chat
    func addImageInChats(imagData:Data) -> Int{
        messages.append(Messgae(sender: checkSenderType(senderType: "is_poster", botTitle: ""), messageId: "xx12cd", sentDate: Date(), kind: .photo(Media(image: UIImage(data: imagData)!, realImageUrl: "")), downloadURL: ""))
        notifyBool.append(false)
        notifyStatus.append("sending")
        messagesTime.append("\(Date())")
        reloadAfterSending()
        return messages.count - 1
    }
    
    //MARK: create dictonary for sending Image Message
    //. Method recevies base64 of image and taskId
    //. Returns Image Message dictonary for sendMessage Api
    func createSendImageDictionary(imageBase64:Data,taskId:String)->[String:Any]{
        
        var dictionary = [String:Any]()
        dictionary["attachment"] = imageBase64.base64EncodedString()
        dictionary["extension"] = "jpeg"
        dictionary["task_id"] = taskId
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
            
        return dictionary
    }
    
    //MARK: when video is selected from gallery
    //.Video is appended into chat
    func sendVideo(dataOfVideo:Data, videoLink:URL){
        var dictionary = [String:Any]()
        dictionary["attachment"] = dataOfVideo.base64EncodedString()
        dictionary["user_agent"] = AppPermission.getDeviceInfo()
        dictionary["platform"] = "ios"
        
        ApiManager.sharedInstance.apiCaller(hasBodyData: true, hasToken: true, url: ENDPOINTS.send_message, dictionary: dictionary, httpMethod: "POST", token: UserDefaults.standard.string(forKey: DefaultsKeys.token)) { [self] (Result) in
            switch Result {
            case .success(let response):
                addVideoinChat(messageId: "\(response["message_id"] as! String)", role: "is_poster", videoLink: "\(videoLink)")
            case .failure(_):
                break
            }
        }
    }
    
    //MARK: convert YPMediaVideo video to data and pass to sending function
    //. Receives YPMediaVideo type
    //. create link and data from YPMediaVideo
    func convertAndSendVideo(video:YPMediaVideo){
        let temp = video.url.absoluteURL
        do{
            let dta = try Data(contentsOf: temp)
            sendVideo(dataOfVideo: dta,videoLink: temp)
        }catch{
            //print"error in sending images and videos")
        }
    }

    //MARK: to check gallery is selected or dierrect camera is selected and also send attachements
    //. functions receives ImageType e.g camera/photoLibrary
    //. checks camera or photoLibrary and opens it
    func photoLibrary(imageType:ImageType){
        //open camera or gallery on basis of selected by user.
        switch imageType{
        case .photoLibrary:
            let picker = YPImagePicker(configuration: configurePhotoLibrary())
            picker.didFinishPicking { [self, unowned picker] items, cancelled in
                saveMediaInArray(meadiaArray: items)
                for item in items{
                    switch item{
                    case .photo(p: let p):
                            //resize image
                        let img = resizeImage(image: p.image, targetSize: CGSize(width: 1024, height: 1024))
                        self.sendImage(imageBase64: img.jpegData(compressionQuality: 0.5)!, index: 0, taskId: UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "")
                        break
                    case .video(v: let v):
                        convertAndSendVideo(video: v)
                        break
                    }
                }
                picker.dismiss(animated: true, completion: nil)
            }
            //make apparance of navigation bar white
            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                picker.navigationBar.standardAppearance = appearance
                picker.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
            }
            present(picker, animated: true, completion: nil)
        case .camera:
            openCamera()
        }
    }
    //MARK: open camera to take image
    //. Camera Permission check
    func openCamera(){
        //check is camera is availible on device or not.
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            //check authorization status weather user has granted the camera permission or not.
            //if not ask him to give camera permission.
            let auth = AVCaptureDevice.authorizationStatus(for: .video)
            switch auth {
            case .authorized, .notDetermined:
                myPickerController.sourceType = .camera
                myPickerController.delegate = self
                myPickerController.mediaTypes = ["public.image"]
                myPickerController.allowsEditing = false
                self.present(myPickerController, animated: true, completion: nil)

            default:
                let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!

                let alert = UIAlertController(
                    title: "Need Camera Access",
                    message: "Camera access is required to capture picture.",
                    preferredStyle: UIAlertController.Style.alert
                )
                alert.view.tintColor = UIColor(named: "ButtonColor")
               alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
               alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
                   UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
               }))
                self.present(alert, animated: true, completion: nil)
            }
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                if(!granted && !ChatViewController.camBool){
                    ChatViewController.camBool = true
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }

        }else{
            //HelperFunctions.customAlert(title: Strings.CAMERA_UNAVAILABLE, message: Strings.CAMERA_ERROR, parentController: self)
        }
    }

    //MARK: pick image or video from gallery or capture image from camera
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //called if an image is captured from camera
        if(picker.sourceType == .camera){
            // get orignal image captured from camera
            let imageP = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            //resize image into 1024*1024
            let img = resizeImage(image: imageP!, targetSize: CGSize(width: 1024, height: 1024))
            // send image to chat via api
            self.sendImage(imageBase64: img.jpegData(compressionQuality: 0.5)!, index: 0, taskId: UserDefaults.standard.string(forKey: DefaultsKeys.taskId) ?? "")
            DispatchQueue.main.async {
                //dismiss camera after capturing image.
                self.myPickerController.dismiss(animated: true, completion: nil)
            }
        }

    }
    
}
