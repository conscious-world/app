//
//  MediaTableViewCell.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class MediaTableViewCell: UITableViewCell {
    
    weak var navigationController: UINavigationController!
    var tapGestureRecognizer: UITapGestureRecognizer?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onTap")
        self.userInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer!)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onTap(){
        let storyBoard = UIStoryboard(name: "media_meditation", bundle: nil)
        if let mediaViewController  = storyBoard.instantiateViewControllerWithIdentifier("MediaViewController") as? MediaViewController{
            self.navigationController?.pushViewController(mediaViewController, animated: true)
        }
    }

}
