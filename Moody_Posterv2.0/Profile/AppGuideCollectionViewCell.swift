//
//  AppGuideCollectionViewCell.swift
//  Moody_Posterv2.0
//
//  Created by Syed Mujtaba Hassan on 30/11/2021.
//

import UIKit

class AppGuideCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var appGuideImages: UIImageView!
    
    //MARK: sets imgae of slide 
    func setup(_ slide: Slide){
        
        appGuideImages.image = slide.image
    }
}
