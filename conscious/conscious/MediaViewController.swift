//
//  MediaViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/4/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import AVFoundation
import Player

class MediaViewController: UIViewController, AVAudioPlayerDelegate, UIViewControllerTransitioningDelegate, MentalStateDelegate, UIGestureRecognizerDelegate, PlayerDelegate {

    @IBAction func onBackPressed(sender: AnyObject) {
        // TODO:
        // handle saving meditation history
        // but that should probably happen in the viewWillDissapear method
        if self.playing {
            self.togglePlayingSound()
            self.presentation()
        }
        else if self.meditation != nil && self.meditation!.inProgress(){
            self.presentation()
        }else{
            dismissViewControllerAnimated(true) { () -> Void in
        
            }
        }
    }
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet var mediaView: StarsOverlay!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var VR3DButton: UIButton!
    @IBOutlet weak var backgroundVideoContainer: UIView!
    let videoNames = ["heavenly-rays", "green-sky-in-space","abstract-ocean-with-light-flares", "lights-sea-sparkling_bynqeb", "stars-and-colors-in-space"]
    var player = Player()
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
    var backgroundTaskId: UIBackgroundTaskIdentifier?
    var avSession = AVAudioSession.sharedInstance()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAudio()
        setupPlayButton()
        addBackgroundVideo()
        self.view.backgroundColor = originalColor
        mediaView.setEmitters(true, spin: 130.0)
        timeSlider.setThumbImage(UIImage(named: "lotus-pointer"), forState: .Normal)
        timeSlider.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if first {
            if(meditation == nil){
                meditation = Meditation.newGuidedMeditation()
            }
            first = false
        } else {
        }
        presentation()
        self.player.fillMode = AVLayerVideoGravityResizeAspectFill
        //setBackground()

        UIView.animateWithDuration(1) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.player.playFromBeginning()
    }
    
    func setBackground() {
        UIGraphicsBeginImageContext(self.view.frame.size)
        //UIImage(named: "evileye.jpg")?.drawInRect(self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func setupPlayButton() {
        playPauseButton = PlayPauseButton(frame: playView.bounds)
        playPauseButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        playView.addSubview(playPauseButton)
        let tap = UITapGestureRecognizer(target: self, action: Selector("handlePlayTap:")   )
        tap.delegate = self
        playPauseButton.addGestureRecognizer(tap)
    }
    
    
    func handlePlayTap(sender: UITapGestureRecognizer? = nil){
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
            endBackgroundAudioSession()
            playing = false
        } else {
//            mediaView.setEmitters(false)
            meditation!.start()
            audioPlayer.play()
            startBackgroundAudioSession()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateTimeSlider"), userInfo: nil, repeats: true)
            playing = true
        }
    }
    
    func endBackgroundAudioSession(){
        do{
            try avSession.setActive(false)
        }
        catch {
            NSLog("Error setting up audio session active")
        }
    }
    
    func startBackgroundAudioSession(){
        backgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        do{
            try avSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
        catch _{
            NSLog("Error setting up audio session category:")
        }
        
        do{
            try avSession.setActive(true)
        }
        catch {
            NSLog("Error setting up audio session active")
        }
    }
    
    func mentalStateSelected(picker: MentalStateViewController, didPickState state: String?, color: UIColor?) {
        if let mentalState = state {
            if finished == false {
                mediaView.changeSize(0.5)
                mediaView.changeColor(color!)
                meditation?.mentality_before = mentalState
            } else {
                meditation?.mentality_after = mentalState
            }
        }
    }
    
    func updateTimeSlider () {
        timeSlider.continuous = true
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
    
    var navigteToHomeScreen = true
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if finished {
            if(navigteToHomeScreen){
                navigteToHomeScreen = false
                dispatch_after(0,dispatch_get_main_queue(),{
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                return nil
            }
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
        guard let  audioFilePath = meditation!.pathForMedia else{
            print("no audio media to play so this what are we to do?")
            return //this should probably just crash
        }
       
        minValue = 0
        
        let audioFileUrl = NSURL.fileURLWithPath(audioFilePath)
        
        do {
  
            audioPlayer = try AVAudioPlayer(contentsOfURL: audioFileUrl, fileTypeHint: nil)
            audioPlayer.volume = 0.8
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
    
    
    func addBackgroundVideo(){
        self.player.delegate = self
        self.player.view.frame = self.view.bounds
        self.addChildViewController(player)
        self.backgroundVideoContainer.addSubview(player.view)
        self.player.didMoveToParentViewController(self)
        
        var videoName = videoNames[4]
        if self.meditation?.video_name != nil {
            videoName = (self.meditation!.video_name)!
        }
        
        let urlpath = NSBundle.mainBundle().pathForResource(videoName, ofType: "mp4")
        
        let videoUrl:NSURL = NSURL.fileURLWithPath(urlpath!)
        self.player.setUrl(videoUrl)
        
    }
    
    func playerReady(player: Player) {
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
        player.playFromBeginning()
    }

    @IBAction func on3VRButtonTap(sender: UIButton) {
        
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
