//
//  MediaViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/4/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import AVFoundation

class MediaViewController: UIViewController, AVAudioPlayerDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet var mediaView: UIView!
    
    var animator: MyAnimator = MyAnimator()
    var audioPlayer: AVAudioPlayer!
    var minValue: NSTimeInterval!
    var maxValue: NSDate?
    var timer = NSTimer()
    var duration: Double?
    var playing: Bool = false
    var mediation: Meditation?
    var myPresentation: MyPresentation!
    var isPresenting: Bool = false
    var next = MentalStateViewController!()
    var finished: Bool = false
    var first: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAudio()
        if first {
            presentation()
            first = false
        }
    }
    
    func presentation() {
        let storyBoard = UIStoryboard(name: "mental_state", bundle: nil)
        next = storyBoard.instantiateViewControllerWithIdentifier("MentalStateViewController") as! MentalStateViewController
        next.animator = animator
        next.modalPresentationStyle = .Custom
        next.transitioningDelegate = self
        if first == false {
            next.second = true
        }
        self.presentViewController(next, animated: true, completion: nil)
        myPresentation = MyPresentation(presentedViewController: next, presentingViewController: self)
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        if first {
            next.animator!.presenting = true
            return myPresentation
        } else {
            return nil
        }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if finished {
             self.navigationController?.popViewControllerAnimated(true)
        } else {
            finished = true
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAudio() {
        let audioFilePath = NSBundle.mainBundle().pathForResource("MARC5MinuteBreathing", ofType: "mp3")
        playPauseButton.setImage(UIImage(named: "video-player-7"), forState: UIControlState.Normal)
        playPauseButton.backgroundColor = UIColor.blueColor()
        minValue = 0
        
        if audioFilePath != nil {
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: audioFileUrl, fileTypeHint: nil)
                audioPlayer.delegate = self
                currentTimeLabel.text = minValue.mmss
                duration = self.audioPlayer.duration
                maxValue = NSDate().dateByAddingTimeInterval(duration!)
                timeSlider.minimumValue = Float(minValue)
                timeSlider.maximumValue = Float(duration!)
                timeLeftLabel.text = maxValue?.timeIntervalSinceNow.mmss
            }
            catch {
                fatalError ("Error loading \(audioFileUrl): \(error)")
            }
        } else {
            print("audio file is not found")
        }
    }
    
    @IBAction func togglePlayingSound(sender: AnyObject) {
        if playing {
            print("fake end of mediation")
            mediation?.end()
            History.append(mediation!)
            playPauseButton.setImage(UIImage(named: "video-player-7"), forState: UIControlState.Normal)
            audioPlayer.pause()
            timer.invalidate()
            playing = false
        } else {
            mediation = Meditation.newGuidedMeditation()
            mediation!.start()
            audioPlayer.play()
            playPauseButton.setImage(UIImage(named: "pushpin-7"), forState: UIControlState.Normal)
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateTimeSlider"), userInfo: nil, repeats: true)
            playing = true
        }
    }
    
    func updateTimeSlider () {
        timeSlider.value = Float(audioPlayer.currentTime)
        currentTimeLabel.text = audioPlayer.currentTime.mmss
        let diff = Float(duration!) - timeSlider.value
        timeLeftLabel.text  = NSTimeInterval(diff).mmss
    }
    
    @IBAction func scrubTimeSlider(sender: AnyObject) {
        let scrubbedValue = NSTimeInterval(timeSlider.value)
        audioPlayer.currentTime = scrubbedValue
        currentTimeLabel.text = scrubbedValue.mmss
        let diff = Float(duration!) - timeSlider.value
        timeLeftLabel.text = NSTimeInterval(diff).mmss
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playPauseButton.setImage(UIImage(named: "video-player-7"), forState: UIControlState.Normal)
        // segue to post-meditation screen
        presentation()
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

private let DURATION:NSTimeInterval = 0.35
class MyAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
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

class MyPresentation: UIPresentationController {
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

extension NSTimeInterval {
    var mmss: String {
        return self < 0 ? "00:00" : String(format:"%02d:%02d", Int((self/60.0)%60), Int(self % 60))
    }
    var hmmss: String {
        return String(format:"%d:%02d:%02d", Int(self/3600.0), Int(self / 60.0 % 60), Int(self % 60))
    }
}
