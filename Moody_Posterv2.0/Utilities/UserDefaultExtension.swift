//
//  UserDefaultExtension.swift
//  Moody_Posterv2.0
//
//  Created by   on 07/06/2021.
//

import Foundation

extension UserDefaults {
    
    //MARK: Resets UserDefaults when user loggouts 
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
    }
}
