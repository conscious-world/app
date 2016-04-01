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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var userAvatar: UIImageView!
    
    var meditation: Meditation?{
        didSet{
            if let newMeditation = meditation{
                if(self.titleLabel != nil){
                    self.titleLabel.text = newMeditation.meditation_title
                    //self.descriptionLabel.text = newMeditation.meditation_description
                    self.coverImage.image = newMeditation.coverImage
                    self.iconImageView.image = UIImage(named: newMeditation.iconName!)
                    self.userAvatar.layer.cornerRadius = 24
                    self.userAvatar.clipsToBounds = true
                    if let avatar = newMeditation.user_avatar_name{
                        self.userAvatar.image = UIImage(named: avatar)
                    }else{
                        self.userAvatar.image = nil
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onTap")
        self.userInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer!)
        if(titleLabel != nil){
            titleLabel.layer.shadowOpacity = 0.8
            titleLabel.layer.shadowRadius = 6.0
            titleLabel.layer.shadowColor = UIColor.blackColor().CGColor
            titleLabel.layer.shadowOffset = CGSizeMake(0.0, -1.0)
        }
//        self.iconContainerView.layer.cornerRadius = 24
//        self.iconContainerView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onTap(){
        let storyBoard = UIStoryboard(name: "media_meditation", bundle: nil)
        if let mediaViewController  = storyBoard.instantiateViewControllerWithIdentifier("MediaViewController") as? MediaViewController{
            mediaViewController.modalPresentationStyle = .OverFullScreen
            mediaViewController.meditation = self.meditation
            self.window?.rootViewController!.presentViewController(mediaViewController, animated: true, completion: nil)
        }
    }



}
