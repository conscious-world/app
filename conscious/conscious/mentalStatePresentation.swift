//
//  mentalStatePresentation.swift
//  conscious
//
//  Created by William Johnson on 3/15/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class MentalStatePresentation: UIPresentationController {

    
    var dimView: UIView!
        override func presentationTransitionWillBegin() {
            dimView = UIView(frame: CGRectZero)
            dimView.backgroundColor = UIColor.blackColor()
            dimView.alpha = 0.0
            dimView.frame = CGRectMake(0, 0, 400, 400)
            dimView.frame = (self.containerView?.bounds)!
            self.containerView?.addSubview(dimView)
            self.presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ (context) -> Void in
                self.dimView.alpha = 0.3
                }, completion: { (finished) -> Void in
            })
            
        }

}
