//
//  TaskerDetailsView.swift
//  Moody_Posterv2.0
//
//  Created by Umer yasin on 17/08/2021.
//

import UIKit
import SDWebImage

class TaskerDetailsView: UITableViewCell {

    @IBOutlet weak var fullyOuterView: UIView!
    @IBOutlet weak var taskeName: UILabel!
    @IBOutlet weak var vehicleNumber: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    
    //MARK:  called when this view is initialized.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fullyOuterView.roundCorners(corners: [.topRight,.bottomLeft,.bottomRight], radius: 10)
        if(UserDefaults.standard.string(forKey: DefaultsKeys.taskerNameDetail) != nil){
            taskeName.text = UserDefaults.standard.string(forKey: DefaultsKeys.taskerNameDetail)
        }else{
            taskeName.text = "Not Available"
        }
        
        if(UserDefaults.standard.string(forKey: DefaultsKeys.VehicleNumber) != ""){
            vehicleNumber.text = UserDefaults.standard.string(forKey: DefaultsKeys.VehicleNumber)
        }else{
            vehicleNumber.text = " "
        }
        
        if(UserDefaults.standard.double(forKey: DefaultsKeys.RatingOfTasker) != 0.0){
            rating.text = "\(UserDefaults.standard.double(forKey: DefaultsKeys.RatingOfTasker))"
        }else{
            rating.text = "0.0"
        }
        if(UserDefaults.standard.string(forKey: DefaultsKeys.taskerProfileImage) != nil && UserDefaults.standard.string(forKey: DefaultsKeys.taskerProfileImage) != ""){
            DispatchQueue.global().async {

            SDWebImageManager.shared.loadImage(with: URL(string: UserDefaults.standard.string(forKey: DefaultsKeys.taskerProfileImage)!), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                if error == nil{
                    if data != nil {
                        DispatchQueue.main.async {
                            self.img.image = UIImage(data: data!)
                        }
                    }else if image != nil{
                        DispatchQueue.main.async {
                            self.img.image = image
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.img.image = UIImage(named: "person2")
                        }
                    }
                  
                }else{
                    DispatchQueue.main.async {
                        self.img.image = UIImage(named: "person2")
                    }
                }
            }
        }
            
        }else{
            self.img.image = UIImage(named: "person2")
        }


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
