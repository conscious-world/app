//
//  CategoryTableViewCell.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    weak var navigationController: UINavigationController!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CategoryTableViewCell.onTap))
        self.userInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onTap(){
        print("tap")
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let timerViewController  = storyBoard.instantiateViewControllerWithIdentifier("CategoryViewController") as? CategoryViewController{
            print("launch view controller")
            self.navigationController?.pushViewController(timerViewController, animated: true)
        }
    }

}
