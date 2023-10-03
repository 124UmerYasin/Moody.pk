//
//  TaskStatusView.swift
//  Moody_Posterv2.0
//
//  Created by mujtaba Hassan on 23/08/2021.
//

import UIKit

class TaskStatusView: UITableViewCell {

    @IBOutlet weak var taskStatusLbl: UILabel!
    @IBOutlet weak var outterView: UIView!
    
    //MARK: called when this view is initialized
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outterView.roundCorners(corners: [.allCorners], radius: 5)
        taskStatusLbl.text = UserDefaults.standard.string(forKey: DefaultsKeys.taskStatusMessage)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
