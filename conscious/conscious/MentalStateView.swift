//
//  MentalStateView.swift
//  conscious
//
//  Created by William Johnson on 3/11/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

@IBDesignable class MentalStateView: UIView {



    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        // sets the image's frame to fill our view
        let nib = UINib(nibName: "MentalStateView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
//        contentView.frame = contentView.bounds
//        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//        addSubview(contentView)
        
        
        // caption has translucent grey background 30 points high and span across bottom of view
//        let captionBackgroundView = UIView(frame: CGRectMake(0, bounds.height - 30, bounds.width, 30))
//        captionBackgroundView.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
//        addSubview(captionBackgroundView)
//        
//        mentalStateLabel = UILabel(frame: captionBackgroundView.bounds.insetBy(dx: 10, dy: 5))
//        mentalStateLabel.text = "hello!"
////        mentalStateLabel.textColor = UIColor.blackColor()
//        captionBackgroundView.addSubview(mentalStateLabel)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
