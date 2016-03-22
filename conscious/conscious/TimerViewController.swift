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
    
    //@IBOutlet var starsOverlay: MicVisualizer!
    // set up mentalState
    var mentalStateDelegate: MentalStateDelegate!
    var animator: PresentationAnimator = PresentationAnimator()
    var mentalStatePresentation: MentalStatePresentation!
    var next = MentalStateViewController!()
    var finished: Bool = false
    var first: Bool = true
    
    @IBOutlet var backgroundVisualization: MicVisualizer!
    @IBOutlet weak var controlContainerView: UIView!
    
    @IBOutlet weak var plot: EZAudioPlotGL?
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
    

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var tiledBackground: UIView!
    
    var microphone: EZMicrophone!
    var session: AVAudioSession?
    var backgroundTaskId: UIBackgroundTaskIdentifier?
    
    // Status Bar Style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
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

        let tiledTriangleView =   TiledTriangleView(frame: tiledBackground.frame, tileWidth: 100, tileHeight: 75)
        tiledBackground.addSubview(tiledTriangleView)
        self.view.bringSubviewToFront(controlContainerView)
        onSettingsBarBtnTap()
        if first {
            meditation = Meditation.newTimedMeditation()
            self.meditationDescriptionLabel?.text = meditation?.meditation_title
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
    
    @IBAction func onDoneButtonPressed(sender: UIButton) {
        onStopButtonPressed(sender)
        presentation()
    }
    
    @IBAction func onStopButtonPressed(sender: UIButton) {
        meditation!.end()
        //TODO there should be a better end, like taking a survey
        History.append(meditation!)
        EZOutput.sharedOutput().stopPlayback()
        EZMicrophone.sharedMicrophone().stopFetchingAudio()
        userSettings.stopBackgroundSound()
        stopButton.hidden = true
        startButton.hidden = false
        //timerLabel.hidden = true
        timer.invalidate()
    }
    
    @IBAction func onStartButtonPressed(sender: UIButton) {
        meditation!.start()
        startAudio()
        startVisualization()
        updateControlsOnStart()
        userSettings.playBackgroundSound()

        if(userSettings.useAudioReverb()){
           startMicrophonePassthrough()
        }
    }
    
    func startVisualization(){
        self.tiledBackground.alpha = 0.2
    }
    
    func startMicrophonePassthrough(){
        EZMicrophone.sharedMicrophone().startFetchingAudio()
        EZOutput.sharedOutput().startPlayback();
        backgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
    }
    
    func updateControlsOnStart(){
        startButton.hidden = true
        stopButton.hidden = false
        timerLabel.hidden = false
        timeLeftLabel.hidden = false
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
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
    
    func startAudio()
    {
        self.plot?.backgroundColor = UIColor.clearColor()
        self.plot?.color = UIColor.orangeColor()
        self.plot?.plotType = EZPlotType.Buffer
        
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
            //self.plot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
    
    override func viewDidAppear(animated: Bool) {
        onSettingsBarBtnTap()
    }
    
    override func viewWillAppear(animated: Bool) {
        //settingButton = UIBarButtonItem(title: "⚙", style: UIBarButtonItemStyle.Plain, target: self, action: "onSettingsBarBtnTap")
        //self.navigationItem.rightBarButtonItem = settingButton
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
        let gain = fft.maxFrequencyMagnitude
        let noteName: String = EZAudioUtilities.noteNameStringForFrequency(maxFrequency, includeOctave: true)
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            NSLog("Highest Note: \(noteName),\nFrequency: \(maxFrequency) amplitude: \(gain)")
            self.backgroundVisualization.changeSize(min(4,Double(gain * 20)))
            let color = UIColor(hue: CGFloat(min(1.0,maxFrequency/3000)), saturation: 1.0, brightness: 1.0, alpha: 1.0)
            print("alpha = \(CGFloat(1.0 / Double(gain * 10)))")
            self.backgroundVisualization.changeColor(color)
            //self.tiledBackground.alpha = min(CGFloat(9.0),CGFloat(gain))
                
            

        })
    }
    
    func settingsUpdated(controller: TimerSettingsTableViewController, settings: TimerSettings?){
        if(settings != nil){
            print("settings not nil")
            self.userSettings = settings!
            presentation()
            first = false
        }
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
        print("ask user how they feel")
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
            //play
            onStartButtonPressed(UIButton())
            finished = true
        }
        return nil
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController
        destination.transitioningDelegate = self
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
