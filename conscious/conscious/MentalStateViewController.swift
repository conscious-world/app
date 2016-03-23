//
//  MentalStateViewController.swift
//  conscious
//
//  Created by William Johnson on 3/12/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

@objc protocol MentalStateDelegate {
    func mentalStateSelected(picker: MentalStateViewController, didPickState state: String?, color: UIColor?)
}

class MentalStateViewController: UIViewController, UIViewControllerTransitioningDelegate{
    
    weak var delegate: MentalStateDelegate?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var mentalStateGridView: UIView!
    @IBOutlet weak var mentalStateCursorView: UIView!
    @IBOutlet weak var colorFlower: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var feelingLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    var animator: PresentationAnimator?
    var newPos: CGPoint?
    var startPos: CGPoint?
    var newX: CGFloat?
    var newY: CGFloat?
    var dx: Float!
    var dy: Float!
    var gridCenter: CGPoint?
    var touched: Bool?
    var sectors: [Sector]? = []
    var numberOfSections: Int = 8
    var deltaAngle: Float?
    var originalColor: UIColor = UIColor(hexString: "#FAC54B")
    let rageColor: UIColor = UIColor(hexString: "#f96c6c")
    let fearColor: UIColor = UIColor(hexString: "#b2f96c")
    var amazementColor: UIColor = UIColor(hexString: "#6cf9f9")
    var loathingColor: UIColor = UIColor(hexString: "#b26cf9")
    var joyColor: UIColor = UIColor(hexString: "#f4eb24")


    var sadnessColor: UIColor!
    let terrorColor: UIColor = UIColor(hexString: "#a3cc3f")
    var admirationColor: UIColor = UIColor(hexString: "#cfdd26")
    var vigilanceColor: UIColor!
    //= UIColor(hexString: "#f8a61e")
    var color: UIColor?
    var nextColor: UIColor?
    var second: Bool?
    var state: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeColors()
        // setup Grid
        feelingLabel.alpha = 0.0
        continueButton.alpha = 0.0
        setupGrid()
        createSectors()
        rotateFlower()
        if (second != nil)  {
            questionLabel.text = "How do you feel now?"
        }
    }
    
    func makeColors() {
        vigilanceColor = rageColor.mixWithColor(joyColor)
        sadnessColor = loathingColor.mixWithColor(amazementColor)
    }
    
    func rotateFlower() {
        UIView.animateWithDuration(2.0) { () -> Void in
            self.colorFlower.transform = CGAffineTransformMakeRotation(CGFloat(315.0 * M_PI/180.0))
        }
    }
    
    func setupGrid(){
        mentalStateGridView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mentalStateGridView.layer.position = CGPointMake(contentView.bounds.size.width / 2.0, contentView.bounds.size.height / 2.0)
        startPos = mentalStateGridView.center
        gridCenter = startPos
        mentalStateCursorView.center = startPos!
        view.addSubview(mentalStateGridView)
        
        // set up cursorView
        let backgroundImage = UIImageView(frame: mentalStateCursorView.bounds)
        backgroundImage.image = UIImage(named: "spark")
        self.mentalStateCursorView.insertSubview(backgroundImage, atIndex: 0)
        mentalStateCursorView.layer.masksToBounds = false
        mentalStateCursorView.backgroundColor = UIColor.clearColor()
        mentalStateCursorView.layer.cornerRadius = mentalStateCursorView.frame.size.width/2
        mentalStateCursorView.clipsToBounds = true
    }
    
    func createSectors(){
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
            switch (sector.sector!){
            case 0:
                sector.type = "sadness"
                sector.color = sadnessColor
            case 1:
                sector.type = "loathing"
                sector.color = loathingColor
            case 2:
                sector.type = "rage"
                sector.color = rageColor
            case 3:
                sector.type = "vigiliance"
                sector.color = vigilanceColor
            case 4:
                sector.type = "joy"
                sector.color = joyColor
            case 5:
                sector.type = "admiration"
                sector.color = admirationColor
            case 6:
                sector.type = "terror"
                sector.color = fearColor
            case 7:
                sector.type = "amazement"
                sector.color = amazementColor
            default:
                sector.type = "undefined"
                sector.color = originalColor
            }
            mid -= angleSize
            sectors!.append(sector)
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
                UIView.animateWithDuration(1.35, animations: { () -> Void in
                    self.feelingLabel.alpha = 1.0
                    self.questionLabel!.alpha = 0.0
                    self.hintLabel!.alpha = 0.0
                })
            }
        } else if gesture.state == UIGestureRecognizerState.Changed {
            dx = Float(mentalStateCursorView.center.x - gridCenter!.x)
            dy = Float(mentalStateCursorView.center.y - gridCenter!.y)
            var distFromCenter: Float = 0
            let radians: CGFloat = CGFloat(atan2f(Float(dx), Float(dy)))
            var sector: Int = 0
            var weight: CGFloat = 0
            for s: Sector in sectors! {
                if radians > CGFloat(s.minValue!) && radians < CGFloat(s.maxValue!) {
                    sector = s.sector!
                } else {
                    // Get the Outlier sector, always half the number of sections
                    if s.minValue > s.maxValue && (radians > CGFloat(s.minValue!) || -radians > CGFloat(s.minValue!)) {
                        sector = numberOfSections/2
                    }
                    if dx == 0 && dy == 0 {
                        //                    sector = 10
                    }
                }
                color = sectors![sector].color
                var triangulation = sqrt((dx*dx) + (dy*dy))
                distFromCenter = 1 - Float(triangulation)/Float(190.0)
                
                if triangulation < 45 {
                    
                }
                
                if triangulation > 45 && triangulation < 90 {
                    
                }
                
                if triangulation > 90  {
                    
                }
                
            }
            color = color!.tintColor(amount: CGFloat(distFromCenter))
            makeTinyRipple(color, size: distFromCenter)
            setText(distFromCenter, sector: sector)
            newX = (startPos!.x + translation.x)
            newY = (startPos!.y + translation.y)
            mentalStateCursorView.center = CGPoint(x: newX!, y: newY!)
            
        } else if gesture.state == UIGestureRecognizerState.Ended {
            isSelected()
            touched = true
            mentalStateCursorView.alpha = 0.0
            mentalStateCursorView.center = startPos!
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.mentalStateCursorView.alpha = 1.0
            })
        }
    }
    
    func isSelected() {
        UIView.animateWithDuration(1.0) { () -> Void in
            self.view.tintColor = self.color!
            self.continueButton.alpha = 1.0
        }
    }
    
    @IBAction func onContinuePressed(sender: AnyObject) {
        makeRipple()
        delegate?.mentalStateSelected(self, didPickState: self.state, color: color)
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "dismissView", userInfo:nil ,repeats: false)
    }
    
    
    func makeTinyRipple(color: UIColor!, size: Float) {
        var option = Ripple.option()
        var scale: Float?
    //configure
        option.duration = CFTimeInterval(1.0)
        option.borderColor = UIColor.clearColor()
        option.fillColor = color
        if size == 0 {
            scale = 0.75
        } else if size == 1.0 {
            scale = 0.75
        }
        else if size < 0.1 {
            scale = 1.0
        } else if size > 0.1 {
            scale = Float(1 - size/4)
        }
        print(scale,size)
        option.scale = CGFloat(4 * scale!)
        option.borderWidth = CGFloat(2.0 * scale!)
        option.radius = CGFloat(20.0 * scale!)
    
        Ripple.run(mentalStateCursorView, locationInView: CGPoint(x: 25,y: 20),     option: option){
        }
    }
    
    func makeRipple() {
        var option = Ripple.option()
        //configure
        option.borderWidth = CGFloat(2.0)
        option.radius = CGFloat(40.0)
        option.duration = CFTimeInterval(1.3)
//        option.borderColor = UIColor.whiteColor().tintColor(amount: 0.7)
        option.fillColor = color!
        option.scale = CGFloat(40)
        
        Ripple.run(mentalStateCursorView, locationInView: CGPoint(x: 25,y: 20), option: option){
        }
    }
    
    
    func dismissView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changeColor(tint: Float, color: UIColor) {
        UIView.animateWithDuration(1.0) { () -> Void in
//            self.mentalStateGridView.backgroundColor = color.tintColor(amount: CGFloat(tint))
        }
    }
    
    func mergeColor(nextColor: UIColor?, weight: Float?) {
        UIView.animateWithDuration(1.0) { () -> Void in
//            self.mentalStateGridView.backgroundColor = self.color?.mixWithColor(nextColor!,weight: CGFloat(weight!))
        }
    }
    
    func setText(tint: Float, sector: Int){
        var text: String = questionLabel.text!
        let joy = ["serenity", "joy", "ecstasy"]
        let fear = ["apprehension", "fear", "terror"]
        let sadness = ["pensiveness", "sadness", "grief"]
        let anger = ["annoyance", "anger", "rage"]
        let vigilance = ["interest", "anticipation", "vigilance"]
        let admiration = ["acceptance","trust","admiration"]
        let amazement = ["distraction","surprise","amazement"]
        let loathing = ["boredom","disgust","loathing"]
        let combos = ["remorse", "contempt", "aggressive", "optimistic", "love", "submission", "awe"]
        
        var index: Int = 0
        
        if tint < 0.28 {
            //TODO: For combos, pull in the radians to determine which combo it should be
            index = 2
        }
        if tint >= 0.28 && tint <= 0.54 {
            index = 1
        }
        if tint > 0.54 && tint < 0.80 {
            index = 0
        }
        if tint >= 0.8 {
            return
        }
        if sector == 0 {
            text = sadness[index]
        }
        if sector == 1 {
            text = loathing[index]
        }
        if sector == 2 {
            text = anger[index]
        }
        if sector == 3 {
            text = vigilance[index]
        }
        if sector == 4 {
            text = joy[index]
        }
        if sector == 5 {
            text = admiration[index]
        }
        if sector == 6 {
            text = fear[index]
        }
        if sector == 7 {
            text = amazement[index]
        }
        if self.sectors![sector].type != nil {
            UIView.animateWithDuration(1.35) { () -> Void in
                self.questionLabel!.alpha = 1.0
                self.questionLabel.text = text
                self.questionLabel.textColor = self.color
            }
        }
        self.state = text
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return MentalStatePresentation(presentedViewController: presented, presentingViewController: presenting)
    }
    
    /*
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let destinationVC:MediaViewController = segue.destinationViewController as! MediaViewController
    
    //set properties on the destination view controller
    }
    */
}

