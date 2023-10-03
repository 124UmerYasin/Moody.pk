//
//  BundleExtension.swift
//  Moody_Posterv2.0
//
//  Created by   on 07/06/2021.
//

import Foundation
import UIKit

private var kBundleKey: UInt8 = 0
//MARK: Sets Language of application and orientation respect to language
class BundleEx: Bundle {

    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &kBundleKey) {
            return (bundle as! Bundle).localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }

}

extension Bundle {

    static let once: Void = {
        object_setClass(Bundle.main, type(of: BundleEx()))
    }()

    //MARK: Checks and Sets Language orientation
    class func setLanguage(_ language: String?) {
        Bundle.once
        let isLanguageRTL = Bundle.isLanguageRTL(language)
        if (isLanguageRTL) {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            UISwitch.appearance().semanticContentAttribute = .forceLeftToRight
            UITextView.appearance().textAlignment = .right
            UITextField.appearance().textAlignment = .right
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            UISwitch.appearance().semanticContentAttribute = .forceLeftToRight
            UITextView.appearance().textAlignment = .left
            UITextField.appearance().textAlignment = .left
        }
        UserDefaults.standard.set(isLanguageRTL, forKey: "AppleTextDirection")
        UserDefaults.standard.set(isLanguageRTL, forKey: "NSForceRightToLeftWritingDirection")
        UserDefaults.standard.synchronize()

        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            return
        }
        objc_setAssociatedObject(Bundle.main, &kBundleKey, Bundle(path: path), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    //MARK: Returns if language is RTL
    class func isLanguageRTL(_ languageCode: String?) -> Bool {
        return (languageCode != nil && Locale.characterDirection(forLanguage: languageCode!) == .rightToLeft)
    }

}
