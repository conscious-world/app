//
//  TimerViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import AudioToolbox

class TimerViewController: UIViewController, EZMicrophoneDelegate, EZAudioFFTDelegate, TimerSettingsTableViewControllerDelegate, UIViewControllerTransitioningDelegate, MentalStateDelegate {
    
    var settingButton : UIBarButtonItem?
    
    @IBOutlet var starsOverlay: StarsOverlay!
    // set up mentalState
    var mentalStateDelegate: MentalStateDelegate!
    var animator: PresentationAnimator = PresentationAnimator()
    var mentalStatePresentation: MentalStatePresentation!
    var next = MentalStateViewController!()
    var finished: Bool = false
    var first: Bool = true
    
    @IBOutlet weak var controlContainerView: UIView!
    
    @IBOutlet weak var plot: EZAudioPlotGL?
    @IBOutlet weak var backgroundView: UIWebView!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var maxFrequencyLabel: UILabel!
    @IBOutlet weak var meditationDescriptionLabel: UILabel!
    
    let FFTViewControllerFFTWindowSize:vDSP_Length = 4096;
    var fft: EZAudioFFTRolling!
    var timer = NSTimer()
    var counter = 0
    var meditation: Meditation?
    var userSettings = TimerSettings.getCurrentSettings()
    
    let traySmallHeight = 200
    @IBOutlet weak var trayHeightContraint: NSLayoutConstraint!
    
    var trayPanGestureRecognizer:UIPanGestureRecognizer?
    var trayStartY = CGPoint()
    
    @IBAction func onTrayPanGesure(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.view)
        translation.y
        

        let point = sender.locationInView(self.view)
        
        if sender.state == UIGestureRecognizerState.Began {
            print("Gesture began at: \(point)")
        } else if sender.state == UIGestureRecognizerState.Changed {
            translation.y
            print("translation.y \(translation.y)")
            trayHeightContraint.constant = trayHeightContraint.constant - translation.y
            sender.setTranslation(CGPointZero, inView: self.view)
            print("Gesture changed at: \(point)")
        } else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(1.0, animations: {
                
                if(self.controlHiden){
                   //no-op
                }else{
                    if(self.trayHeightContraint.constant >= 220){
                        self.trayHeightContraint.constant =
                            self.view.frame.height
                        self.controlHiden = true
                    }else{
                         self.trayHeightContraint.constant = 200
                    }
                }
                //self.view.layoutIfNeeded()
                
                })

        }
    }
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    var microphone: EZMicrophone!
    var session: AVAudioSession?
    var backgroundTaskId: UIBackgroundTaskIdentifier?
    
    // Status Bar Style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    func getTringle(tringleView:UIView, index:Int) -> UIView{
    
        // Build a triangular path
        
        let path = UIBezierPath()
       
        if(index % 2 == 0){
             path.moveToPoint(CGPoint(x: 0,y: 0))
            path.addLineToPoint(CGPoint(x: 50,y: 75))
            path.addLineToPoint(CGPoint(x: 100,y: 0))
            path.addLineToPoint(CGPoint(x: 0,y: 0))
        }else{
            path.moveToPoint(CGPoint(x: 0,y: 75))
            path.addLineToPoint(CGPoint(x: 50,y: 0))
            path.addLineToPoint(CGPoint(x: 100,y: 75))
            path.addLineToPoint(CGPoint(x: 0,y: 75))
        }
        
        
        // Create a CAShapeLayer with this triangular path
        // Same size as the original imageView
        let mask = CAShapeLayer()
        
        mask.frame = tringleView.bounds;
        mask.path = path.CGPath;
        
        // Mask the imageView's layer with this shape
        tringleView.layer.mask = mask;
        return tringleView
    }
    
    func makeTringles(){
        for yindex in 0...8{
            for xindex in -1...7 {
                let x = CGFloat(xindex * 50)
                let y = CGFloat(yindex * 75)
                var DynamicView=UIView(frame: CGRectMake(x, y, 100, 100))
                DynamicView.backgroundColor=UIColor.clearColor()
                
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = DynamicView.bounds
                DynamicView.addSubview(blurEffectView)
                
                DynamicView = getTringle(DynamicView, index: (xindex + yindex))
                self.view.addSubview(DynamicView)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.plot?.backgroundColor = UIColor.clearColor()
        //setBackground()
        //self.view.sendSubviewToBack(backgroundView)
        styleButtons()
        controlContainerView.backgroundColor = UIColor.clearColor()
        session = AVAudioSession.sharedInstance()
        self.maxFrequencyLabel.numberOfLines = 0;
        //startAudio()
        timerLabel.hidden = true
        timeLeftLabel.hidden = true
        
        makeTringles()
        self.view.bringSubviewToFront(controlContainerView)
        //self.view.sendSubviewToBack(controlContainerView)

        
        if first {
            meditation = Meditation.newTimedMeditation()
            presentation()
            self.meditationDescriptionLabel?.text = meditation?.meditation_title
            first = false
        } else {
        }
    }
    @IBOutlet weak var conrolContainerBottonConstraint: NSLayoutConstraint!
    var controlHiden = false
   
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            // Back btn Event handler
            presentation()
        }
    }
    
    func styleButtons(){
        let btnAttrs = [NSUnderlineStyleAttributeName : 0]
        let startTitleStr = NSMutableAttributedString(string:"▶︎ Begin", attributes:btnAttrs)
        startButton.setAttributedTitle(startTitleStr, forState: .Normal)
        let stopTitleStr = NSMutableAttributedString(string:"◼︎ Stop", attributes:btnAttrs)
        stopButton.setAttributedTitle(stopTitleStr, forState: .Normal)
    }
    
    
    @IBAction func onStopButtonPressed(sender: UIButton) {
        meditation!.end()
        //TODO there should be a better end, like taking a survey
        History.append(meditation!)
        EZOutput.sharedOutput().stopPlayback()
        EZMicrophone.sharedMicrophone().stopFetchingAudio()
        userSettings.stopBackgroundSound()
        sender.hidden = true
        startButton.hidden = false
        //timerLabel.hidden = true
        timer.invalidate()
    }
    
    @IBAction func onStartButtonPressed(sender: UIButton) {
        meditation!.start()
        startAudio()
        userSettings.playBackgroundSound()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        sender.hidden = true
        stopButton.hidden = false
        timerLabel.hidden = false
        timeLeftLabel.hidden = false
        if(userSettings.useAudioReverb()){
            EZMicrophone.sharedMicrophone().startFetchingAudio()
            EZOutput.sharedOutput().startPlayback();
            backgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        }
    }
    
    func updateCounter(){
        if(counter % Int(userSettings.intervalSeconds) == 0){
            userSettings.playReminderTone()
        }
        let secondsLeft = (Int(userSettings.intervalSeconds) - counter)
        timerLabel.text = timeFormatted(counter)
        timeLeftLabel.text = timeFormatted(secondsLeft)
        counter = counter + 1
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) //% 60
        //let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
        //return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func setBackground(){
        let path =  NSBundle.mainBundle().bundlePath
        let baseURL = NSURL.fileURLWithPath(path)
        let imageHTML  = "<!DOCTYPE html>" +
            "<html lang=\"ja\"><head>" +
            "<style type=\"text/css\">" +
            "html{background: url('\(userSettings.backgroundGif).gif') no-repeat center center fixed;" +
            " -webkit-background-size: cover; background-size: cover;}" +
            "</style></head><body></body></html>"

        backgroundView.loadHTMLString(imageHTML, baseURL: baseURL)
        backgroundView.userInteractionEnabled = false;
    }
    
    func startAudio()
    {
        self.plot?.backgroundColor = UIColor.clearColor()
        self.plot?.color = UIColor.orangeColor()
        self.plot?.plotType = EZPlotType.Rolling
        self.plot?.shouldFill = true
        self.plot?.shouldMirror = true
        
        do{
            try session!.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
        catch _{
            NSLog("Error setting up audio session category:")
        }
        
        do{
            try session!.setActive(true)
        }
        catch {
            NSLog("Error setting up audio session active")
        }
        
        self.plot?.backgroundColor = UIColor.clearColor()
        self.microphone = EZMicrophone.sharedMicrophone()
        self.microphone.delegate = self
        //EZMicrophone.sharedMicrophone().startFetchingAudio()
        self.microphone.output = ReverbOutput.sharedOutput()
        //EZMicrophone.sharedMicrophone().output = DelayedOutput.sharedOutput()
         self.fft = EZAudioFFTRolling.fftWithWindowSize(FFTViewControllerFFTWindowSize, sampleRate: Float(self.microphone.audioStreamBasicDescription().mSampleRate), delegate: self)
        
        do{
            try session!.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        }
        catch _{
            NSLog("Error setting up audio session active");
            
        }
    }
    
    //EZMicrophoneDelegate
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        self.fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.plot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Timed Mediation"
        settingButton = UIBarButtonItem(title: "⚙", style: UIBarButtonItemStyle.Plain, target: self, action: "onSettingsBarBtnTap")
        self.navigationItem.rightBarButtonItem = settingButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    @IBAction func onControlSettingsButtonTap(sender: UIButton) {
        onSettingsBarBtnTap()
    }
    func onSettingsBarBtnTap(){
        
        let storyBoard = UIStoryboard(name: "timed_meditation", bundle: nil)
        if let settingsViewController  = storyBoard.instantiateViewControllerWithIdentifier("TimerSettingsTableViewController") as? TimerSettingsTableViewController{
            settingsViewController.delegate = self
            settingsViewController.modalPresentationStyle = .OverFullScreen
            settingsViewController.view.backgroundColor = UIColor.clearColor()
            self.presentViewController(settingsViewController, animated: true, completion: nil)
           // self.navigationController?.pushViewController(settingsViewController, animated: true)
        }
    }
    
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        let maxFrequency: Float = fft.maxFrequency
        
        let noteName: String = EZAudioUtilities.noteNameStringForFrequency(maxFrequency, includeOctave: true)
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            NSLog("Highest Note: \(noteName),\nFrequency: \(maxFrequency)")
        })
    }
    
    func settingsUpdated(controller: TimerSettingsTableViewController, settings: TimerSettings){
        self.userSettings = settings
    }
    
    func mentalStateSelected(picker: MentalStateViewController, didPickState state: String?, color: UIColor?) {
        if let mentalState = state {
            if finished == false {
                meditation?.mentality_before = mentalState
            } else {
                meditation?.mentality_after = mentalState
            }
        }
    }
    
    func presentation() {
        return
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
