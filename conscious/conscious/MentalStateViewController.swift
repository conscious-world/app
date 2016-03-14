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

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var mentalStateGridView: UIView!
    @IBOutlet weak var mentalStateCursorView: UIView!
    
    var mentalStateView: MentalStateView?
    var animator: MyAnimator?
    var newPos: CGPoint?
    var startPos: CGPoint?
    var numberOfSections: Int = 4
    var im: UILabel!
    var originalColor: UIColor = UIColor(hexString: "#FAC54B")
    var xScale: Float?
    var yScale: Float?
    var newX: CGFloat?
    var newY: CGFloat?
    var deltaAngle: Float?
    var gridCenter: CGPoint?
    var sectors: [Sector]? = []
    let joyColor: UIColor = UIColor.yellowColor()
    let fearColor: UIColor = UIColor.greenColor()
    let sadnessColor: UIColor = UIColor.blueColor()
    let rageColor: UIColor = UIColor.redColor()
    var color: UIColor?
    var dx: Float!
    var dy: Float!
    var second: Bool?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let v = UIView(frame: CGRectMake(0, 0, 400, 400))
        v.backgroundColor = UIColor.clearColor()
        mentalStateGridView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mentalStateGridView.layer.position = CGPointMake(contentView.bounds.size.width / 2.0, contentView.bounds.size.height / 2.0)
        startPos = mentalStateGridView.center
        gridCenter = startPos
        mentalStateCursorView.center = startPos!
        mentalStateGridView.backgroundColor = originalColor.tintColor(amount: 0.8)
        
        self.view = contentView
        view.addSubview(mentalStateGridView)
        let angleSize: CGFloat = CGFloat(2 * M_PI / Double(numberOfSections))
        var mid: CGFloat = 0
        for var i = 0; i < numberOfSections; i++ {
            
            let sector: Sector = Sector()
            sector.midValue = mid
            sector.minValue = mid - (angleSize/2)
            sector.maxValue = mid + (angleSize/2)
            sector.sector = i
            if Double(sector.maxValue! - angleSize) < -M_PI {
                mid = CGFloat(M_PI)
                sector.midValue = mid
                sector.minValue = CGFloat((fabsf(Float(sector.maxValue!))))
            }
            mid -= angleSize
            sectors!.append(sector)
        }
        
        let backgroundImage = UIImageView(frame: mentalStateCursorView.bounds)
        backgroundImage.image = UIImage(named: "buddha")
        self.mentalStateCursorView.insertSubview(backgroundImage, atIndex: 0)
        
        mentalStateCursorView.layer.borderWidth = 1.0
        mentalStateCursorView.layer.masksToBounds = false
        mentalStateCursorView.layer.borderColor = UIColor.grayColor().CGColor
        mentalStateCursorView.layer.cornerRadius = mentalStateCursorView.frame.size.width/2
        mentalStateCursorView.clipsToBounds = true
        
        if (second != nil)  {
            questionLabel.text = "How do you feel now?"
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mentalStateCursorPanned(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(mentalStateGridView)
        
        if gesture.state == UIGestureRecognizerState.Began {
            if questionLabel.alpha != 0.0 {
                UIView.animateWithDuration(0.35, animations: { () -> Void in
                    self.questionLabel!.alpha = 0.0
                })
            }
        } else if gesture.state == UIGestureRecognizerState.Changed {
            dx = Float(mentalStateCursorView.center.x - gridCenter!.x)
            dy = Float(mentalStateCursorView.center.y - gridCenter!.y)
            newX = (startPos!.x + translation.x)
            newY = (startPos!.y + translation.y)
            var distFromCenter: Float = 0
            let radians: CGFloat = CGFloat(atan2f(Float(dx), Float(dy)))
            var sector: Int = 10
            for s: Sector in sectors! {
                if radians > CGFloat(s.minValue!) && radians < CGFloat(s.maxValue!) {
                    sector = s.sector!
                } else {
                    // Get the Outlier sector, always half the number of sections
                    if s.minValue > s.maxValue && (radians > CGFloat(s.minValue!) || -radians > CGFloat(s.minValue!)) {
                        sector = numberOfSections/2
                    }
                if dx == 0 && dy == 0 {
                    sector = 10
                }
                }
                switch (sector) {
                    case 0:
                        distFromCenter = 1 - dy/Float((self.mentalStateGridView.frame.height/2))
                        color = sadnessColor
                    case 1:
                        distFromCenter = 1 - -dx/Float((self.mentalStateGridView.frame.width/2))
                        color = rageColor
                    case 2:
                        distFromCenter = 1 - -dy/Float((self.mentalStateGridView.frame.height/2))
                        color = joyColor
                    case 3:
                        distFromCenter = 1 - dx/Float((self.mentalStateGridView.frame.width/2))
                        color = fearColor
                    default:
                        // TODO:: Setup color mixing
                        if dx != 0 || dy != 0 {
                            color = color!.mixWithColor(UIColor.blueColor())
                        }
                }

            }
            mentalStateCursorView.center = CGPoint(x: newX!, y: newY!)
            changeColor(distFromCenter, color: color!)
//            setText(distFromCenter, sector: sector)
        } else if gesture.state == UIGestureRecognizerState.Ended {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
            mentalStateCursorView.center = startPos!
            mentalStateGridView.backgroundColor = originalColor.tintColor(amount: 0.8)
        }
    }
    
    func changeColor(tint: Float, color: UIColor) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.mentalStateGridView.backgroundColor = color.tintColor(amount: CGFloat(tint))
        }
    }
    
    func setText(tint: Float, sector: Int){
        var text: String = questionLabel.text!
        let joy = ["serentiy", "joy", "ecstasy"]
        let fear = ["apprehension", "fear", "terror"]
        let sadness = ["pensiveness", "sadness", "grief"]
        let anger = ["annoyance", "anger", "rage"]
        var index: Int = 0
        
        if tint < 0.33 {
            index = 2
        }
        if tint >= 0.33 && tint <= 0.66 {
            index = 1
        }
        if tint > 0.66 {
            index = 0
        }
        if sector == 0 {
            text = sadness[index]
        }
        if sector == 1 {
            text = anger[index]
        }
        if sector == 2 {
            text = joy[index]
        }
        if sector == 3 {
            text = fear[index]
        }
        UIView.animateWithDuration(0.35) { () -> Void in
            self.questionLabel.text = text
            self.questionLabel!.alpha = 1.0
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

class Sector: NSObject {
    var minValue: CGFloat?
    var maxValue: CGFloat?
    var midValue: CGFloat?
    var sector: Int?
}

