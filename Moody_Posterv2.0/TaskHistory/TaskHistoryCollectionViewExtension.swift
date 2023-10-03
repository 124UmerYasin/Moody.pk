//
//  TaskHistoryCollectionViewExtension.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 04/06/2021.
//

import Foundation
import UIKit


//MARK: Month Collection View implementation

class MonthCell: UICollectionViewCell{
    @IBOutlet var MonthCellLabel: UILabel!
}

extension TaskHistoryViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
                                //MARK: CollectionView Delegates
    
    //MARK: Sets number of items in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months.count
    }
    
    
    //MARK: Sets name, color of each item in collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath) as! MonthCell
        cell.MonthCellLabel.attributedText = NSAttributedString(string: months[indexPath.row], attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12.0)])
        if indexPath.row == selectedMonth {
            cell.MonthCellLabel.textColor = .black
        }else{
            cell.MonthCellLabel.textColor = .lightGray
        }
        return cell
    }
    
    //MARK: Dectects when item (mnonth) is selected in collection view
    //. Swipes collectionView to selected month
    //. Update History data in tableView
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        loaderUIUpdate(isAnimating: false)
        selectedMonth = indexPath.row
        UserDefaults.standard.setValue(selectedMonth, forKey: DefaultsKeys.selectedHistoryMonth)
        var date:String = ""
        
        if(selectedMonth < 9){
            date = "\(Date().currentYear)-0\(selectedMonth + 1)"
            UserDefaults.standard.setValue(date, forKey: DefaultsKeys.selectedDate)
            
            TaskHistoryCollectionView.scrollToItem(at:IndexPath(item: selectedMonth, section: 0), at: .centeredHorizontally, animated: true)
        }
        else{
            date = "\(Date().currentYear)-\(selectedMonth + 1)"
            UserDefaults.standard.setValue(date, forKey: DefaultsKeys.selectedDate)
        
            TaskHistoryCollectionView.scrollToItem(at:IndexPath(item: selectedMonth, section: 0), at: .centeredHorizontally, animated: true)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "goingOutFromHistory"), object: nil)
        setTasksHistoryDictionary(date: date)
        collectionView.reloadData()
        
    }
    
    
}

extension UICollectionView {
    //MARK: Scroll to next months on button press
    func scrollToNextItem() {
        if self.contentOffset.x != self.bounds.size.width {
            let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
            self.moveToFrame(contentOffset: contentOffset)
        }
    }
    //MARK: Slide to next or prevous months.
    func moveToFrame(contentOffset : CGFloat) {
            self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
    //MARK: Scroll to previous months on button press
    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(-self.contentOffset.x + self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
}


