//
//  UserCell.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 09/06/2021.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class UserCell: UICollectionViewCell {
    //MARK: - IBOutlets
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var bitrateLabel: UILabel!
    @IBOutlet var callTimerLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: - Properties
    var videoView: UIView? {
        didSet {
            guard let view = videoView else {
                return
            }
            
            containerView.insertSubview(view, at: 0)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }
    }
    
    /**
     *  Mute user block action.
     */
    var didPressMuteButton: ((_ isMuted: Bool) -> Void)?
    
    var connectionState: QBRTCConnectionState = .connecting {
        didSet {
            switch connectionState {
            case .new: statusLabel.text = "New"
            case .pending: statusLabel.text = "Pending"
            case .connected: statusLabel.text = "Connected"
            case .closed: statusLabel.text = "Closed"
            case .failed: statusLabel.text = "Failed"
            case .hangUp: statusLabel.text = "Hung Up"
            case .rejected: statusLabel.text = "Rejected"
            case .noAnswer: statusLabel.text = "No Answer"
            case .disconnectTimeout: statusLabel.text = "Time out"
            case .disconnected: statusLabel.text = "Disconnected"
            case .unknown: statusLabel.text = ""
            default: statusLabel.text = ""
            }
            muteButton.isHidden = !(connectionState == .connected)
        }
    }
    
    var name = "" {
        didSet {
            nameLabel.text = name
            nameView.isHidden = name.isEmpty
            //nameView.backgroundColor = PlaceholderGenerator.color(index: name.count)
            muteButton.isHidden = name.isEmpty
        }
    }
    
    var bitrate: Double = 0.0 {
        didSet {
            if bitrate == 0.0 {
                bitrateLabel.text = ""
            } else if bitrate > 0.0 {
                bitrateLabel.text = String(format: "%.0f kbits/sec", bitrate * 1e-3)
            }
        }
    }
    
    let unmutedImage = UIImage(named: "ic-qm-videocall-dynamic-off")!
    let mutedImage = UIImage(named: "ic-qm-videocall-dynamic-on")!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        bitrateLabel.backgroundColor = UIColor(red: 0.9441, green: 0.9441, blue: 0.9441, alpha: 0.350031672297297)
        muteButton.setImage(unmutedImage, for: .normal)
        muteButton.setImage(mutedImage, for: .selected)
        muteButton.isHidden = true
        muteButton.isSelected = false
    }
    
    //MARK: - Actions
    @IBAction func didPressMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        didPressMuteButton?(sender.isSelected)
    }
}

class User {
    //MARK - Properties
    private var user: QBUUser!
    var connectionState: QBRTCConnectionState = .connecting
    var userName: String {
        return user.fullName ?? CallConstant.unknownUserLabel
    }
    
    var userID: UInt {
        return user.id
    }
    
    var bitrate: Double = 0.0
    
    //MARK: - Life Cycle
    required init(user: QBUUser) {
        self.user = user
    }
}

struct UsersDataSourceConstant {
    static let userCellIdentifier = "UserCell"
}

class UsersDataSource: NSObject {
    
    // MARK: - Properties
    var selectedUsers = [QBUUser]()
    private var users = [QBUUser]()
    
    func update(users: [QBUUser]) {
        for chatUser in users {
            update(user:chatUser)
        }
    }
    
    func update(user: QBUUser) {
        if let localUser = users.filter({ $0.id == user.id }).first {
            //Update local User
            localUser.fullName = user.fullName
            localUser.updatedAt = user.updatedAt
            return
        }
        users.append(user)
    }
    
    func selectUser(at indexPath: IndexPath) {
        
        let user = usersSortedByLastSeen()[indexPath.row]
        if selectedUsers.contains(user) {
            selectedUsers.removeAll(where: { element in element == user })
        } else {
            selectedUsers.append(user)
        }
    }
    
    func user(withID ID: UInt) -> QBUUser? {
        return users.filter{ $0.id == ID }.first
    }
    
    
    func ids(forUsers users: [QBUUser]) -> [NSNumber] {
        
        var result = [NSNumber]()
        
        for user in users {
            result.append(NSNumber(value: user.id))
        }
        return result
    }
    
    func removeAllUsers() {
        users.removeAll()
    }
    
    func usersSortedByFullName() -> [QBUUser] {
        let sortedUsers = unsortedUsersWithoutMe().sorted(by: {
            guard let firstUserName = $0.fullName, let secondUserName = $1.fullName else {
                return false
            }
            return firstUserName < secondUserName
        })
        return sortedUsers
    }
    
    func usersSortedByLastSeen() -> [QBUUser] {
        let sortedUsers = unsortedUsersWithoutMe().sorted(by: {
            guard let firstUpdatedAt = $0.updatedAt, let secondUpdatedAt = $1.updatedAt else {
                return false
            }
            return secondUpdatedAt < firstUpdatedAt
        })
        return sortedUsers
    }
    
    func unsortedUsersWithoutMe() -> [QBUUser] {
        var unsorterUsers = self.users
        let profile = Profile()
        if profile.isFull == false {
            return unsorterUsers
        }
        guard let index = unsorterUsers.index(where: { $0.id == profile.ID }) else {
            return unsorterUsers
        }
        unsorterUsers.remove(at: index)
        return unsorterUsers
    }
    
    //MARK: - Load User from server
    func loadUser(_ id: UInt, completion: ((QBUUser?) -> Void)? = nil) {
        QBRequest.user(withID: id, successBlock: { [weak self] (response, user) in
            self?.update(user: user)
            completion?(user)
        }) { (response) in
            completion?(nil)
        }
    }
}

extension UsersDataSource: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersSortedByLastSeen().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UsersDataSourceConstant.userCellIdentifier)
            as? UserTableViewCell else {
                return UITableViewCell()
        }
        
        let user = usersSortedByLastSeen()[indexPath.row]
        let selected = selectedUsers.contains(user)
        
        let size = CGSize(width: 32.0, height: 32.0)
        var name = user.fullName ?? ""
        if name.isEmpty {
            name = user.login ?? "Unknown user"
        }
        let userImage = PlaceholderGenerator.placeholder(size: size, title: name)
        cell.fullName = name
        cell.check = selected
        cell.userImage = userImage
        
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let str = String(format: "Select users for call (%tu)", selectedUsers.count)
        return NSLocalizedString(str, comment: "")
    }
}

class UserTableViewCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet private weak var checkView: CheckView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    
    //MARK: - Properties
    var fullName: String? {
        didSet {
            fullNameLabel.text = fullName
        }
    }
    
    var check: Bool? {
        didSet {
            checkView.check = check
        }
    }
    
    var userImage: UIImage? {
        didSet {
            userImageView.image = userImage
        }
    }
}

class CheckView: UIView {
    //MARK: - Properties
    let checkboxNormalImage = UIImage(named: "checkbox-normal")
    let checkboxPressedImage = UIImage(named: "checkbox-pressed")
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView(image: checkboxNormalImage)
        imageView.frame = bounds
        return imageView
    }()
    
    var check: Bool? {
        didSet {
            guard let check = check else { return }
            imageView.image = check ? checkboxPressedImage : checkboxNormalImage
        }
    }
    
    //MARK: - Life Circle
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}
