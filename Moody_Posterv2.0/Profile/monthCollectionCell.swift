//
//  monthCollectionCell.swift
//  Moody_Posterv2.0
//
//  Created by Mobeen Rana on 06/09/2021.
//

import UIKit

class monthCollectionCell: UICollectionViewCell {

    //MARK: -IBOutlets
    @IBOutlet weak var monthLbl: UILabel!
    
    //MARK: - Properties
    
    static var identifier : String { return String(describing: self)
    }
    static var nib : UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

