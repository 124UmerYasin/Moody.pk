//
//  NSMutableExtension.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit


extension NSMutableAttributedString{
    
    //MARK: Shows rating star
    //. Recevies rating in float and returns string which shows rating on label 
    func starWithRating(rating:Float, outOfTotal totalNumberOfStars:NSInteger , withFontSize size:CGFloat) ->NSAttributedString{
        let currentFont = UIFont.systemFont(ofSize: size)
        let activeStarFormat = [ NSAttributedString.Key.font: currentFont,
                                 NSAttributedString.Key.foregroundColor: UIColor(named: "ButtonColor")];
        let inactiveStarFormat = [ NSAttributedString.Key.font:currentFont, NSAttributedString.Key.foregroundColor: UIColor(named: "lightGray-1")];
        
        let starString = NSMutableAttributedString()
        for i in 0 ..< totalNumberOfStars{
            if (rating >= Float(i+1)){ starString.append(NSAttributedString(string: "\u{22C6}", attributes: activeStarFormat)) }
            else if (rating > Float(i)){ starString.append(NSAttributedString(string: "\u{E1A1}", attributes: activeStarFormat)) }
            else{ starString.append(NSAttributedString(string: "\u{22C6}", attributes: inactiveStarFormat)) }
        }
        return starString
    }
}
