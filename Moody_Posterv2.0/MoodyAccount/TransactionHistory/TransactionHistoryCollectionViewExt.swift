//
//  TransactionHistoryCollectionViewExt.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 05/06/2021.
//

import Foundation
import UIKit

//MARK: Label in Month Collection view cell
class monthCell: UICollectionViewCell{
    @IBOutlet var MonthCellLabel: UILabel!
}

    //MARK: Delgates of collection view

//MARK: Returns number of section in collection view
extension TransactionHistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months.count
    }
        
    //MARK: Returns all cells in collectionView
    //. Styling of cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monthCell", for: indexPath) as! monthCell
        cell.MonthCellLabel.attributedText = NSAttributedString(string: months[indexPath.row], attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12.0)])
        if indexPath.row == selectedMonth {
            cell.MonthCellLabel.textColor = .black
        }else{
            cell.MonthCellLabel.textColor = .lightGray
        }
        return cell
    }
    
    //MARK: Calls when month is selected from collection view 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        loaderUIUpdate(isAnimating: false)
        selectedMonth = indexPath.row
        var date:String = ""
        
        if(selectedMonth < 9){
            date = "\(Date().currentYear)-0\(selectedMonth + 1)"
        }
        else{
            date = "\(Date().currentYear)-\(selectedMonth + 1)"
        }
        setTransactionHistoryDictionary(date: date)
        collectionView.reloadData()
        
    }
    
}
