//
//  CollectionViewCell.swift
//  Gallery
//
//  Created by Shahina Kassim on 11/12/23.
//

import UIKit
protocol DeleteDelegate{
   func deleteAction(index: Int)
}
class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var photo: UIImageView!
    var index: Int?
    var delegate: DeleteDelegate?
   
    @IBAction func selectButtonClicked(_ sender: Any) {
        
        if let item = index{
         //   selectedButton.backgroundColor = UIColor.blue
            delegate?.deleteAction(index: item)
            
        }
    }
    func configureCell(imageURL: URL, indexItem : Int, isEditing: Bool, isSelectedForDelete: Bool)
    {
        
        if isEditing{
            selectedButton.isHidden = false
            index = indexItem
            DispatchQueue.main.async {
                
               
                if isSelectedForDelete{
                    self.selectedButton.imageView?.image = UIImage(systemName: "circle.inset.filled")
                }else{
                    self.selectedButton.imageView?.image = UIImage(systemName: "circle")
                }
            }
        }else{
            self.selectedButton.isHidden = true
        }
        
        
        
        if let image = UIImage(contentsOfFile: imageURL.path) {
            photo.image = image
        } else {
            // Handle the case where loading the image fails
            photo.image = UIImage(systemName: "photo")
        }
        
    }
    
}
