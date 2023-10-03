//
//  Extension.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 05/06/2021.
//

import Foundation
import UIKit


extension UIViewController{
    
    //MARK: toast functions one function for their contraints and one is for their label and text
    func setToastLabelConstraints(message: String, font: UIFont) -> UILabel{
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = .white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        return toastLabel
    }
    
    
    //MARK: Genraic method to show toast
    func showToast(message: String, font: UIFont) {
        let toastLabel = setToastLabelConstraints(message: message, font: font)
        let maxWidthPercentage: CGFloat = 0.8
        let maxTitleSize = CGSize(width: view.bounds.size.width * maxWidthPercentage, height: view.bounds.size.height * maxWidthPercentage)
        var titleSize = toastLabel.sizeThatFits(maxTitleSize)
        titleSize.width += 20
        titleSize.height += 10
        toastLabel.frame = CGRect(x: view.frame.size.width / 2 - titleSize.width / 2, y: view.frame.size.height - 100, width: titleSize.width, height: titleSize.height)
        let windows = UIApplication.shared.windows
        windows.last?.addSubview(toastLabel)
        UIView.animate(withDuration: 1, delay: 1.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
