//
//  Profile.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 09/06/2021.
//
import UIKit
import Foundation
import Quickblox

struct UserProfileConstant {
    static let curentProfile = "curentProfile"
}

class Profile: NSObject  {
    
    // MARK: - Public Methods
    class func currentUser() -> User? {
        guard let current = Profile.loadObject() else {
            return nil
        }
        let user = User(user: current)
        return user
    }
    
    class func clearProfile() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserProfileConstant.curentProfile)
    }
    
    class func synchronize(_ user: QBUUser) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: UserProfileConstant.curentProfile)
        } catch {
            //print"Couldn't write file to UserDefaults")
        }
    }
    
    class func update(_ user: QBUUser) {
        if let current = Profile.loadObject() {
            if let fullName = user.fullName {
                current.fullName = fullName
            }
            if let login = user.login {
                current.login = login
            }
            if let password = user.password {
                current.password = password
            }
            Profile.synchronize(current)
        } else {
            Profile.synchronize(user)
        }
    }
    
   //MARK: - Internal Class Methods
    private class func loadObject() -> QBUUser? {
        let userDefaults = UserDefaults.standard
        guard let decodedUser  = userDefaults.object(forKey: UserProfileConstant.curentProfile) as? Data else { return nil }
        do {
            if let user = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decodedUser) as? QBUUser {
                return user
            }
        } catch {
            //print"Couldn't read file from UserDefaults")
            return nil
        }
        return nil
    }
    
    //MARK - Properties
    var isFull: Bool {
        return user != nil
    }
    
    var ID: UInt {
        return user!.id
    }
    
    var login: String {
        return user!.login!
    }
    
    var password: String {
        return user!.password!
    }
    
    var fullName: String {
        return user!.fullName!
    }
    
    var tags: [String]? {
        return user!.tags
    }
    
    private var user: QBUUser? = {
        return Profile.loadObject()
    }()
}


struct StatsViewConstants {
    static let statsReportPlaceholderText = "Loading stats report..."
}

class StatsView: UIView {
    //MARK: - Properties
    lazy private var statsLabel: UILabel = {
        let statsLabel = UILabel(frame: bounds)
        statsLabel.text = StatsViewConstants.statsReportPlaceholderText
        statsLabel.numberOfLines = 0
        statsLabel.font = UIFont(name: "Roboto", size: 12.0)
        statsLabel.adjustsFontSizeToFitWidth = true
        statsLabel.minimumScaleFactor = 0.6
        statsLabel.textColor = UIColor.green
        return statsLabel
    }()
    
    override var isHidden: Bool {
        didSet {
            if isHidden == true {
                updateStats(nil)
            }
        }
    }
    
    //MARK: - Life Cycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(statsLabel)
        backgroundColor = UIColor(white: 0.0, alpha: 0.6)
    }
    
    override func layoutSubviews() {
        statsLabel.frame = bounds
    }
    
    //MARK: - Internal Methods
    func updateStats(_ stats: String?) {
        statsLabel.text = stats ?? StatsViewConstants.statsReportPlaceholderText
    }
}

class PlaceholderGenerator {
    //MARK: - Properties
    static let instance = PlaceholderGenerator()
    
    private lazy var cache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "QMUserPlaceholer.cache"
        cache.countLimit = 200
        return cache
    }()
    
    private let colors: [UIColor] = [#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.3035047352, green: 0.8693258762, blue: 0.4432001114, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.02297698334, green: 0.6430568099, blue: 0.603818357, alpha: 1), #colorLiteral(red: 0.5244195461, green: 0.3333674073, blue: 0.9113605022, alpha: 1), #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1), #colorLiteral(red: 0.839125216, green: 0.871129334, blue: 0.3547145724, alpha: 1), #colorLiteral(red: 0.09088832885, green: 0.7803853154, blue: 0.8577881455, alpha: 1), #colorLiteral(red: 0.3175504208, green: 0.4197517633, blue: 0.7515394688, alpha: 1)]
    
    //MARK: - Class Methods
    class func color(index: Int) -> UIColor {
        return PlaceholderGenerator.instance.color(index: index)
    }
    
    class func placeholder(size: CGSize, title: String?) -> UIImage {
        let key = title ?? ""
        if let image = PlaceholderGenerator.instance.cache.object(forKey: key as AnyObject) as? UIImage {
            return image
        } else {
            let index = key.count % 10
            let image = placeholder(size: size,
                                    color: PlaceholderGenerator.instance.color(index: index),
                                    title: title,
                                    isOval: true)
            PlaceholderGenerator.instance.cache.setObject(image, forKey: key as AnyObject)
            return image
        }
    }
    
    class func placeholder(size: CGSize, color: UIColor, title: String?, isOval: Bool) -> UIImage {
        let minSize = min(size.width, size.height)
        let frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let path = isOval ? UIBezierPath(ovalIn: frame) : UIBezierPath(rect: frame)
        color.setFill()
        path.fill()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let font = UIFont.systemFont(ofSize: minSize / 2.0)
        let textColor = UIColor.white
        let titleString = NSString(string: title ?? "Q")
        
        let textContent = titleString.substring(to: 1).uppercased()
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: textColor,
                                                         .paragraphStyle: paragraphStyle]
        
        let rect = textContent.boundingRect(with: frame.size,
                                            options: .usesLineFragmentOrigin,
                                            attributes: attributes,
                                            context: nil)
        
        let textRect = rect.offsetBy(dx: (size.width - rect.width) / 2.0,
                                     dy: (size.height - rect.height) / 2.0)
        
        textContent.draw(in: textRect, withAttributes: attributes)
        //Get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    class func rect(withIndex idx: Int, size: Int, count: Int) -> CGRect {
        let heightValue: Int = count > 2 ? size / 2 : size
        let widthValue: Int = size / 2
        
        switch idx {
        case 0:
            return CGRect(x: 0,
                          y: 0,
                          width: widthValue,
                          height: count < 4 ? size : size / 2)
        case 1:
            return CGRect(x: widthValue,
                          y: 0,
                          width: widthValue,
                          height: heightValue)
        case 2:
            return CGRect(x: count < 4 ? widthValue : 0,
                          y: widthValue,
                          width: widthValue,
                          height: heightValue)
        case 3:
            return CGRect(x: widthValue,
                          y: widthValue,
                          width: widthValue,
                          height: heightValue)
        default:
            return CGRect.zero
        }
    }
    
    //MARK: - Internal Methods
    private func color(index: Int) -> UIColor {
        let color = colors[index % colors.count]
        return color
    }
}

struct UsersConstant {
    static let answerInterval: TimeInterval = 10.0
    static let pageSize: UInt = 50
    static let aps = "aps"
    static let alert = "alert"
    static let voipEvent = "VOIPCall"
}

struct UsersAlertConstant {
    static let checkInternet = NSLocalizedString("Please check your Internet connection", comment: "")
    static let okAction = NSLocalizedString("Ok", comment: "")
    static let shouldLogin = NSLocalizedString("You should login to use VideoChat API. Session hasn’t been created. Please try to relogin.", comment: "")
    static let logout = NSLocalizedString("Logout...", comment: "")
}

struct UsersSegueConstant {
    static let settings = "PresentSettingsViewController"
    static let call = "CallViewController"
    static let sceneAuth = "SceneSegueAuth"
}
