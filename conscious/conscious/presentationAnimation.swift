//
//  presentationAnimation.swift
//  conscious
//
//  Created by William Johnson on 3/15/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class PresentationAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    private let DURATION:NSTimeInterval = 0.35
        var presenting: Bool = false
        func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            return DURATION
        }
        
        func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView()
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            toView.frame = container!.bounds
            
            if presenting {
                toView.alpha = 0.0
                container?.addSubview(toView)
                UIView.animateWithDuration(DURATION, animations: { () -> Void in
                    toView.alpha = 1.0
                    }) { (finished) -> Void in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                }
                
            } else {
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    }) { (finished: Bool) -> Void in
                        transitionContext.completeTransition(true)
                        fromView.removeFromSuperview()
                }
            }
        }
}
