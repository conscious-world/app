//
//  MentalStateViewController.swift
//  conscious
//
//  Created by William Johnson on 3/12/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

let Pi = CGFloat(M_PI)
let DegreesToRadians = Pi / 180
let RadiansToDegrees = 180 / Pi

class MentalStateViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mentalStateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var mentalStateGridView: UIView!
    @IBOutlet weak var mentalStateCursorView: UIView!
    
    var mentalStateView: MentalStateView?
    var animator: MyAnimator?
    var newPos: CGPoint?
    var startPos: CGPoint?
    var numberOfSections: Int = 4
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let v = UIView(frame: CGRectMake(0, 0, 400, 400))
        v.backgroundColor = UIColor.clearColor()
        mentalStateGridView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        startPos = mentalStateGridView.center
        print(startPos)
        mentalStateCursorView.center = startPos!
        self.view = contentView
        view.addSubview(mentalStateGridView)
        var angleSize: CGFloat = 2*M_PI/numberOfSections
        
        
        mentalStateGridView.layer.borderWidth = 1.0
        mentalStateGridView.layer.masksToBounds = false
        mentalStateGridView.layer.borderColor = UIColor.grayColor().CGColor
        mentalStateGridView.layer.cornerRadius = mentalStateGridView.frame.size.width/3
        mentalStateGridView.clipsToBounds = true
        
        mentalStateCursorView.layer.borderColor = UIColor.grayColor().CGColor
        mentalStateCursorView.layer.cornerRadius = mentalStateCursorView.frame.size.width/2
        mentalStateCursorView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mentalStateCursorPanned(gesture: UIPanGestureRecognizer) {
        let point = gesture.locationInView(mentalStateGridView)
        let translation = gesture.translationInView(mentalStateGridView)
        
        var newX: CGFloat?
        var newY: CGFloat?
        
        if gesture.state == UIGestureRecognizerState.Began {
            print("Gesture began at: \(point)")
            startPos = mentalStateCursorView.center
        } else if gesture.state == UIGestureRecognizerState.Changed {
            print("Gesture changed at: \(point)")
            
            newX = (startPos!.x + translation.x)
            newY = (startPos!.y + translation.y)
            mentalStateCursorView.center = CGPoint(x: newX!
                , y: newY!)
    
            
        } else if gesture.state == UIGestureRecognizerState.Ended {
            print("done")
        }
    }
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return MyPresentation(presentedViewController: presented, presentingViewController: presenting)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

