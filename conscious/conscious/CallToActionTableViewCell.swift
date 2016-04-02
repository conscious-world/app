//
//  CallToActionTableViewCell.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import Spring

class CallToActionTableViewCell: UITableViewCell {

    weak var navigationController: UINavigationController!
    var lastMeditation: Meditation?
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ctaButton.layer.cornerRadius = 10
        self.ctaButton.clipsToBounds = true
        if let lastMeditation = History.sharedInstance()?.last{
            let mediationName = lastMeditation.meditation_type.stringByReplacingOccurrencesOfString("_", withString: " ")
            self.ctaButton.setTitle("Start \(mediationName)", forState: UIControlState.Normal)
            self.lastMeditation = lastMeditation
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()


    }
    
    func resizeLogo(height: CGFloat){
        let heightContraints:[NSLayoutConstraint] = self.logoImage.constraints.filter({ (constraint) -> Bool in
            //print("\(constraint.firstAttribute)")
            if constraint.firstItem as! UIImageView == self.logoImage{
                constraint.constant = height
                return true
            }
            return false
        })
        
        //print("heightContraints.count \(heightContraints.count)")
        
        self.layoutIfNeeded()
    }
    
    @IBOutlet weak var headerBackgroundHeightConstraint: NSLayoutConstraint!
    func resizeHeader(height: CGFloat){
        print("resizeHeader")
        
        headerBackgroundHeightConstraint.constant = height
        
        self.layoutIfNeeded()
    }

    @IBOutlet weak var ctaButton: SpringButton!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func onCTAClick(sender: UIButton) {
        openActivity()
    }

    
    func openActivity(){
        
        guard let lastMeditation = self.lastMeditation else {
            navigateToTimedMeditation()
            return
        }
        
        if lastMeditation.meditation_type == Meditation.timed_mediation_type{
            navigateToTimedMeditation()
        }
        else{
            navigateToTimedMedation()
        }
    }
    
    func navigateToTimedMeditation(){
        if let tabController = self.window?.rootViewController as? GlobalTabBarViewController{
            tabController.selectedIndex = 1
        }
    }
    
    func navigateToTimedMedation(){
        let storyBoard = UIStoryboard(name: "media_meditation", bundle: nil)
        if let mediaViewController  = storyBoard.instantiateViewControllerWithIdentifier("MediaViewController") as? MediaViewController{
            mediaViewController.modalPresentationStyle = .OverFullScreen
            mediaViewController.meditation = self.lastMeditation
            self.window?.rootViewController!.presentViewController(mediaViewController, animated: true, completion: nil)
        }
    }

}
