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
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ctaButton.layer.cornerRadius = 10
        self.ctaButton.clipsToBounds = true
        if let last_medaition = History.sharedInstance()?.last{
            let mediationName = last_medaition.meditation_type.stringByReplacingOccurrencesOfString("_", withString: " ")
            self.ctaButton.setTitle("Start \(mediationName)", forState: UIControlState.Normal)
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
    
    func resizeHeader(height: CGFloat){
        print("resizeHeader")
        let topContraints:[NSLayoutConstraint] = self.headerImage.constraints.filter({ (constraint) -> Bool in
            print("\(constraint.firstAttribute)")
            if constraint.firstItem as! UIImageView == self.headerImage && constraint.firstAttribute == NSLayoutAttribute.Height {
                constraint.constant = height
                return true
            }
            return false
        })
        
        print("heightContraints.count \(topContraints.count)")
        
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
        if let last_medaition = History.sharedInstance()?.last{
            if last_medaition.meditation_type == Meditation.guided_mediation_type{
                let storyBoard = UIStoryboard(name: "media_meditation", bundle: nil)
                if let mediaViewController  = storyBoard.instantiateViewControllerWithIdentifier("MediaViewController") as? MediaViewController{
                    mediaViewController.meditation = History.sharedInstance()?.last
                    self.window!.rootViewController?.presentViewController(mediaViewController, animated: true, completion: nil)
                    return
                }
            }
        }
        //else lets start a timed meditaion
        let storyBoard = UIStoryboard(name: "timed_meditation", bundle: nil)
            if let vc = self.window!.rootViewController{
                vc.performSegueWithIdentifier("toTimedMeditationSegue", sender: self)
            }
    }
    
    func openActivityInNavigationController(){
        if let last_medaition = History.sharedInstance()?.last{
            if last_medaition.meditation_type == Meditation.guided_mediation_type{
                let storyBoard = UIStoryboard(name: "media_meditation", bundle: nil)
                if let mediaViewController  = storyBoard.instantiateViewControllerWithIdentifier("MediaViewController") as? MediaViewController{
                    self.navigationController?.pushViewController(mediaViewController, animated: true)
                    //exit now
                    return
                }
            }
        }
        //else lets start a timed meditaion
        let storyBoard = UIStoryboard(name: "timed_meditation", bundle: nil)
        if let timerViewController  = storyBoard.instantiateViewControllerWithIdentifier("TimerViewController") as? TimerViewController{
            self.navigationController?.pushViewController(timerViewController, animated: true)
        }
    }

}
