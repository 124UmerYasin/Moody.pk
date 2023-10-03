//
//  CallSettings.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 09/06/2021.
//

import Foundation
import UIKit
import QuickbloxWebRTC

struct SettingsConstants {
    static let videoFormatKey = "videoFormat"
    static let preferredCameraPosition = "cameraPosition"
    static let mediaConfigKey = "mediaConfig"
}

class Settings {
    
    init() {
        load()
    }
    
    //MARK: - Properties
    var videoFormat = QBRTCVideoFormat.default()
    var mediaConfiguration = QBRTCMediaStreamConfiguration.default()
    var preferredCameraPostion: AVCaptureDevice.Position = .front
    
    //MARK: - Public Methods
    func saveToDisk() {
        // saving to disk
        let defaults = UserDefaults.standard
        do {
            let videFormatData = try NSKeyedArchiver.archivedData(withRootObject: videoFormat, requiringSecureCoding: false)
            let mediaConfig = try NSKeyedArchiver.archivedData(withRootObject: mediaConfiguration, requiringSecureCoding: false)
            defaults.set(preferredCameraPostion.rawValue, forKey: SettingsConstants.preferredCameraPosition)
            defaults.set(videFormatData, forKey: SettingsConstants.videoFormatKey)
            defaults.set(mediaConfig, forKey: SettingsConstants.mediaConfigKey)
            defaults.synchronize()
        } catch {
            //print"Couldn't write file to UserDefaults")
        }
    }
    
    func applyConfig() {
        // saving to config
        QBRTCConfig.setMediaStreamConfiguration(mediaConfiguration)
    }
    
    private func load() {
        let defaults = UserDefaults.standard
        let defaultCameraPosition = defaults.integer(forKey: SettingsConstants.preferredCameraPosition)
        if let postion = AVCaptureDevice.Position(rawValue: defaultCameraPosition) {
            preferredCameraPostion = postion == .unspecified ? .front : postion
        }
        do {
            if let videoFormatData = defaults.object(forKey: SettingsConstants.videoFormatKey) as? Data,
               let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(videoFormatData) {
                videoFormat = data as? QBRTCVideoFormat ?? QBRTCVideoFormat.default()
            }
            if let mediaConfigData = defaults.object(forKey: SettingsConstants.mediaConfigKey) as? Data,
               let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(mediaConfigData) {
                mediaConfiguration = data as? QBRTCMediaStreamConfiguration ?? QBRTCMediaStreamConfiguration.default()
            }
        } catch {
            //print"Couldn't read file from UserDefaults")
        }
        applyConfig()
    }
}

class OpponentsFlowLayout: UICollectionViewFlowLayout {
    
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // MARK: Construction
    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        minimumInteritemSpacing = 2
        minimumLineSpacing = 2
    }
    
    // MARK: UISubclassingHooks
    override var collectionViewContentSize: CGSize {
        return collectionView?.frame.size ?? CGSize.zero
    }
    
    override func prepare() {
        layoutAttributes.removeAll()
        guard let collectionView = collectionView else {
            return
        }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        for item in 0..<(numberOfItems) {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
            attributes.frame = itemFrame(index: item, count: numberOfItems)
            layoutAttributes.append(attributes)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter {
            let intersection = rect.intersection($0.frame)
            return intersection.isNull == false
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func shiftPosition(itemsCount: Int, isPortrait: Bool) -> Int {
        // ItemsCount : position
        guard isPortrait == true else {
            let map = [5: 3,
                       7: 4,
                       10: 8]
            return map[itemsCount] ?? .max
        }
        
        let map = [3: 0,
                   5: 0,
                   7: 6,
                   8: 6,
                   10: 9,
                   11: 9,
                   13: 12,
                   14: 12]
        
        return map[itemsCount] ?? .max
    }
    
    func itemFrame(index: Int, count: Int) -> CGRect {
        let size = collectionViewContentSize
        let isPortrait = size.width < size.height
        let columnsCount = numberOfColumns(itemsCount: count, isPortrait: isPortrait)
        
        guard count > 1 else {
            return CGRect(origin: .zero, size: size)
        }
        
        let position = shiftPosition(itemsCount: count, isPortrait: isPortrait)
        let shift = index > position ? 1 : 0
        
        let mod = count % columnsCount
        
        let square = Double(count)
        let side = Double(columnsCount)
        
        let rows = (square / side).rounded(.up)
        
        var scale = 1.0 / side
        if position == index {
            if columnsCount == 2 {
                scale = 1.0
            } else if columnsCount == 3 {
                scale = mod == 1 ? 1.0 : Double(mod) / side
            } else if columnsCount == 4 {
                scale = 2.0 / side
            }
        }
        
        let width = Double(size.width) * scale
        let height = Double(size.height) / rows
        let slip = Double(index + shift)
        
        let row = (slip / side).rounded(.down)
        let slipMod = (index + shift) % columnsCount
        
        let originX = width * Double(slipMod).rounded()
        let originY = height * row
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    private func numberOfColumns(itemsCount: Int, isPortrait: Bool) -> Int {
        guard isPortrait == true else {
            switch itemsCount {
            case 1: return 1
            case 2, 4: return 2
            case 3, 5, 6, 9: return 3
            default: return 4
            }
        }
        
        switch itemsCount {
        case 1, 2: return 1
        case 3, 4, 5, 6: return 2
        default: return 3
        }
    }
}


struct ButtonsFactoryConstants {
    static let rect = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
    static let declineRect = CGRect(x: 0.0, y: 0.0, width: 96.0, height: 44.0)
    static let circleDeclineRect = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
    
    static let backgroundColor = UIColor(red: 0.8118, green: 0.8118, blue: 0.8118, alpha: 1.0)
    static let selectedColor = UIColor(red: 0.3843, green: 0.3843, blue: 0.3843, alpha: 1.0)
    static let declineColor = UIColor(red: 0.8118, green: 0.0, blue: 0.0784, alpha: 1.0)
    static let answerColor = UIColor(red: 0.1434, green: 0.7587, blue: 0.1851, alpha: 1.0)
}

class ButtonsFactory {
    // MARK: - Class Methods
    class func button(withFrame frame: CGRect, backgroundColor: UIColor, selectedColor: UIColor) -> CustomButton {
        let button = CustomButton(frame: frame)
        button.backgroundColor = backgroundColor
        button.selectedColor = selectedColor
        return button
    }
    
    class func iconView(withNormalImage normalImage: String, selectedImage: String) -> UIImageView? {
        let icon = UIImage(named: normalImage)
        let selectedIcon = UIImage(named: selectedImage)
        let iconView = UIImageView(image: icon, highlightedImage: selectedIcon)
        iconView.contentMode = .scaleAspectFit
        return iconView
    }
    
    class func videoEnable() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor:ButtonsFactoryConstants.backgroundColor, selectedColor: ButtonsFactoryConstants.selectedColor)
        button.pushed = true
        button.iconView = self.iconView(withNormalImage: "camera_on_ic", selectedImage: "camera_off_ic")
        return button
    }
    
    class func audioEnable() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor: ButtonsFactoryConstants.backgroundColor, selectedColor: ButtonsFactoryConstants.selectedColor)
        button.pushed = true
        button.iconView = self.iconView(withNormalImage: "mute_on_ic", selectedImage: "mute_off_ic")
        return button
    }
    
    class func dynamicEnable() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor: ButtonsFactoryConstants.backgroundColor, selectedColor: ButtonsFactoryConstants.selectedColor)
        button.pushed = true
        button.iconView = self.iconView(withNormalImage: "ic_volume_low", selectedImage: "ic_volume_high")
        return button
    }
    
    class func screenShare() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor: ButtonsFactoryConstants.backgroundColor, selectedColor: ButtonsFactoryConstants.selectedColor)
        button.iconView = self.iconView(withNormalImage: "screensharing_ic", selectedImage: "screensharing_ic")
        return button
    }
    
    class func answer() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor: ButtonsFactoryConstants.answerColor, selectedColor: ButtonsFactoryConstants.selectedColor)
        button.iconView = self.iconView(withNormalImage: "answer", selectedImage: "answer")
        return button
    }
    
    class func decline() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.declineRect, backgroundColor: ButtonsFactoryConstants.declineColor, selectedColor: ButtonsFactoryConstants.selectedColor)
        button.iconView = self.iconView(withNormalImage: "decline-ic", selectedImage: "decline-ic")
        return button
    }
    
    class func circleDecline() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.circleDeclineRect, backgroundColor: ButtonsFactoryConstants.declineColor, selectedColor: ButtonsFactoryConstants.selectedColor)
        button.iconView = self.iconView(withNormalImage: "decline-ic", selectedImage: "decline-ic")
        return button
    }
}


