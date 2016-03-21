//
//  MediaViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/4/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import AVFoundation

class MediaViewController: UIViewController, AVAudioPlayerDelegate, UIViewControllerTransitioningDelegate, MentalStateDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet var mediaView: StarsOverlay!
    @IBOutlet weak var playView: UIView!
    var originalColor: UIColor = UIColor(hexString: "#FAC54B")
    
    var smallerView: StarsOverlay?
    var volumeSlider: UISlider?
    var playPauseButton: PlayPauseButton!
    
    var mentalStateDelegate: MentalStateDelegate!
    var animator: PresentationAnimator = PresentationAnimator()
    var playPauseButtonView: UIView!
    var audioPlayer: AVAudioPlayer!
    var minValue: NSTimeInterval!
    var maxValue: NSDate?
    var timer = NSTimer()
    var duration: Double?
    var playing: Bool = false
    var meditation: Meditation?
    var mentalStatePresentation: MentalStatePresentation!
    var next = MentalStateViewController!()
    var finished: Bool = false
    var first: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAudio()
        setupPlayButton()
        self.view.backgroundColor = originalColor
        mediaView.setEmitters(true, spin: 130.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if first {
            meditation = Meditation.newGuidedMeditation()
            presentation()
            first = false
        } else {
        }
        
        UIView.animateWithDuration(1) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func setupPlayButton() {
        playPauseButton = PlayPauseButton(frame: playView.bounds)
        playPauseButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        playView.addSubview(playPauseButton)
        let tap = UITapGestureRecognizer(target: self, action: Selector("handlePlayTap:"))
        tap.delegate = self
        playPauseButton.addGestureRecognizer(tap)
    }
    
    
    func handlePlayTap(sender: UITapGestureRecognizer? = nil){
        print("hey!")
        togglePlayingSound()
        playPauseButton.togglePlaying(playing)
    }
    
    func togglePlayingSound() {
        if playing {
            mediaView.setEmitters(true, spin: 130.0)
            print("togglePlayingSound: fake end of mediation")
            endMeditation()
            audioPlayer.pause()
            timer.invalidate()
            playing = false
        } else {
//            mediaView.setEmitters(false)
            meditation!.start()
            audioPlayer.play()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateTimeSlider"), userInfo: nil, repeats: true)
            playing = true
        }
    }
    
    func mentalStateSelected(picker: MentalStateViewController, didPickState state: String?, color: UIColor?) {
        if let mentalState = state {
            if finished == false {
                mediaView.changeSize(5.0)
                mediaView.changeColor(color!)
                meditation?.mentality_before = mentalState
            } else {
                meditation?.mentality_after = mentalState
            }
        }
    }
    
    func updateTimeSlider () {
        timeSlider.value = Float(audioPlayer.currentTime)
        currentTimeLabel.text = audioPlayer.currentTime.mmss
        let diff = Float(duration!) - timeSlider.value
        timeLeftLabel.text  = NSTimeInterval(diff).mmss
    }
    
    func presentation() {
        let storyBoard = UIStoryboard(name: "mental_state", bundle: nil)
        next = storyBoard.instantiateViewControllerWithIdentifier("MentalStateViewController") as! MentalStateViewController
        next.animator = animator
        next.modalPresentationStyle = .Custom
        next.delegate = self
        next.transitioningDelegate = self
        if first == false {
            next.second = true
        }
        self.presentViewController(next, animated: true, completion: nil)
        mentalStatePresentation = MentalStatePresentation(presentedViewController: next, presentingViewController: self)
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        if first {
            next.animator!.presenting = true
            return mentalStatePresentation
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
    
    func endMeditation() {
        //meditation?.duration = meditation?.time_start - meditation?.time_end
        meditation?.end()
        History.append(meditation!)
    }
    
    @IBAction func scrubTimeSlider(sender: AnyObject) {
        let scrubbedValue = NSTimeInterval(timeSlider.value)
        audioPlayer.currentTime = scrubbedValue
        currentTimeLabel.text = scrubbedValue.mmss
        let diff = Float(duration!) - timeSlider.value
        timeLeftLabel.text = NSTimeInterval(diff).mmss
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
//        playPauseButton.setImage(UIImage(named: "video-player-7"), forState: UIControlState.Normal)
        endMeditation()
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


extension NSTimeInterval {
    var mmss: String {
        return self < 0 ? "00:00" : String(format:"%02d:%02d", Int((self/60.0)%60), Int(self % 60))
    }
    var hmmss: String {
        return String(format:"%d:%02d:%02d", Int(self/3600.0), Int(self / 60.0 % 60), Int(self % 60))
    }
}
