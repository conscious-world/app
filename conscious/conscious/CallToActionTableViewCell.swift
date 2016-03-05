//
//  CallToActionTableViewCell.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class CallToActionTableViewCell: UITableViewCell {

    weak var navigationController: UINavigationController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onCTAClick(sender: UIButton) {
        openActivity()
    }
    
    func openActivity(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let timerViewController  = storyBoard.instantiateViewControllerWithIdentifier("TimerViewController") as? TimerViewController{
            
            self.navigationController?.pushViewController(timerViewController, animated: true)
        }
    }

}
