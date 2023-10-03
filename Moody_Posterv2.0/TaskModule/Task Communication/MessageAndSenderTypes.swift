//
//  MessageAndSenderTypes.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 04/06/2021.
//

import Foundation
import MessageKit
import ReplayKit
import CoreLocation
import SDWebImage

//MARK: these are messages type structs through with it configure or setup them self and display in chat view.
struct sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Messgae: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var downloadURL:String
    
}

struct Media: MediaItem{
    var url: URL?
    var imgData: Data?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    var orignalImage: String
    
    init(image: UIImage,realImageUrl: String) {
        self.orignalImage = realImageUrl
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
    init(imageURL: URL,thumb :UIImage,realImageUrl: String) {
        self.orignalImage = realImageUrl
        if(thumb == UIImage()){
            self.size = CGSize(width: 240, height: 240)
            self.placeholderImage = thumb
            self.image = thumb
            self.url = imageURL
        }else{
            self.size = CGSize(width: 240, height: 240)
            self.placeholderImage = thumb
            self.image = thumb
            self.url = imageURL
        }
    }
}

struct audio:AudioItem{
    var url: URL
    var duration: Float
    var size: CGSize
    init(url: URL) {
        self.url = url
        self.size = CGSize(width: UIScreen.main.bounds.width - 90, height: 50)
        //let audioAsset = AVURLAsset(url: url)
        //self.duration = Float(CMTimeGetSeconds(audioAsset.duration) - 2)
        self.duration = Float(0)
    }
}
struct AttachmentItems: LinkItem {
    var text: String?
    var attributedText: NSAttributedString?
    var url: URL
    var title: String?
    var teaser: String
    var thumbnailImage: UIImage
}


struct CoordinateItem: LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }

}

enum ImageType {
    case photoLibrary
    case camera
}



