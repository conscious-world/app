//
//  TimerViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import AudioToolbox
import Player

class TimerViewController: UIViewController, EZMicrophoneDelegate, EZAudioFFTDelegate, TimerSettingsTableViewControllerDelegate, UIViewControllerTransitioningDelegate, MentalStateDelegate, PlayerDelegate, UIScrollViewDelegate {
    
    var settingButton : UIBarButtonItem?
    
    //@IBOutlet var starsOverlay: MicVisualizer!
    // set up mentalState
    var mentalStateDelegate: MentalStateDelegate!
    var animator: PresentationAnimator = PresentationAnimator()
    var mentalStatePresentation: MentalStatePresentation!
    var next = MentalStateViewController!()
    var first: Bool = true
    
    //@IBOutlet var backgroundVisualization: MicVisualizer!
    
    @IBOutlet weak var plot: EZAudioPlotGL?
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var videoScrollView: UIScrollView!
    
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
        session = AVAudioSession.sharedInstance()
        if self.meditation == nil {
            self.meditation = Meditation.newTimedMeditation()
        }
        configureUI()
        playBackVideos()
    }
    
    @IBOutlet weak var timePicker: TimePickerView!
    
    func configureUI(){
        //todo just hide/show all controles in a view, not each one individually
        timerLabel.hidden = true
        timeLeftLabel.hidden = true
        micButton.hidden = true
        muteButton.hidden = true
        userSettings.useAudioReverb() ? showMicOnButton() : showMicMuteButton()
        self.videoScrollView.delegate = self
        self.videoScrollView.frame = CGRectMake(0,0, self.view.frame.width, self.view.frame.height)
        
        timePicker.settings = userSettings
        timePicker.setValue(UIColor.lightGrayColor(), forKeyPath:"textColor")
        dispatch_async(dispatch_get_main_queue(),{
            self.timePicker.countDownDuration = self.userSettings.intervalSeconds
        })

    }
    

    
    let videoNames = ["abstract-ocean-with-light-flares","heavenly-rays", "green-sky-in-space", "lights-sea-sparkling_bynqeb", "stars-and-colors-in-space"]
    var players: [Player] = []
    
    func playBackVideos(){
        
        let scrollviewHeight = self.videoScrollView.frame.height
        let scrollviewWidth = self.videoScrollView.frame.width
        
        for index in 0...(videoNames.count - 1) {
            players.append(Player())
            players[index].delegate = self
            players[index].view.frame = CGRectMake((CGFloat(index) * scrollviewWidth),0,scrollviewWidth, scrollviewHeight)
            
            self.addChildViewController(players[index])
            self.videoScrollView.addSubview(players[index].view)
            players[index].didMoveToParentViewController(self)
            
            let urlpath = NSBundle.mainBundle().pathForResource(videoNames[index], ofType: "mp4")
            let videoUrl:NSURL = NSURL.fileURLWithPath(urlpath!)
            players[index].setUrl(videoUrl)
        }
        
        self.videoScrollView.contentSize = CGSizeMake(self.videoScrollView.frame.width * CGFloat(videoNames.count), self.videoScrollView.frame.height)
    }
    
    var currentVideoIndex = 0
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentVideoIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        print("page is \(currentVideoIndex)")
        for player in players{
            if player.playbackState == PlaybackState.Playing{
                player.pause()
            }
        }
        players[currentVideoIndex].playFromCurrentTime()
 
        toggleBackgroundSoundEffects()
    }
    
    func toggleBackgroundSoundEffects(){
        //such hack
        if(currentVideoIndex == 2 || currentVideoIndex == 3){
        userSettings.playBackgroundSound()
        }
        else{
        userSettings.stopBackgroundSound()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if self.meditation == nil {
            self.meditation = Meditation.newTimedMeditation()
            configureUI()
        }
        players[0].playFromBeginning()
        //self.player.fillMode = AVLayerVideoGravityResizeAspect
        for player in players{
            player.fillMode = AVLayerVideoGravityResizeAspectFill
        }

    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    @IBAction func onDoneButtonPressed(sender: UIButton) {
        onPauseButtonPressed(sender)
        if(self.meditation!.inProgress()){
            presentation()
        }else{
            navigateToHomeViewController()
        }
        timePicker.hidden = false
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
    
    @IBAction func onPauseButtonPressed(sender: UIButton) {
        stopSound()
        stopButton.hidden = true
        startButton.hidden = false
        micButton.hidden = true
        muteButton.hidden = true
        //timerLabel.hidden = true
        timer.invalidate()
    }
    
    func stopSound(){
        EZOutput.sharedOutput().stopPlayback()
        EZMicrophone.sharedMicrophone().stopFetchingAudio()
        userSettings.stopBackgroundSound()
    }
    
    @IBAction func onStartButtonPressed(sender: UIButton) {
        if(self.meditation!.hasNotStarted()){
            timePicker.hidden = true
            presentation()
            //presentation will call beginMediation() when done
        }else{
            //restart Audio and timer
            startAudio()
            updateControlsToPlaying()
        }
    }
    
    func beginMediation(){
        meditation!.start()
        startAudio()
        updateControlsToPlaying()
    }
    
    var mute = false
    @IBAction func onMuteButtonTapped(sender: UIButton) {
        if(mute){
            mute = false
            startAudio()
            let muteImage = UIImage(named: "ic_volume_up_white_48pt")
            self.muteButton.setImage(muteImage, forState: UIControlState.Normal)
        }
        else{
            mute = true
            stopSound()
            let muteImage = UIImage(named: "ic_volume_off_white_48pt")
            self.muteButton.setImage(muteImage, forState: UIControlState.Normal)
        }
        
        
    }
    @IBAction func onMicButtonTap(sender: UIButton) {
        if(userSettings.useAudioReverb()){
            stopMicrophonePassthrough()
            userSettings.audioEffect = "none"
            showMicMuteButton()
        }else{
            startMicrophonePassthrough()
            userSettings.audioEffect = TimerSettings().audioEffect
            showMicOnButton()
        }
    }
    
    func showMicMuteButton(){
        let muteImage = UIImage(named: "ic_mic_off_white_48pt")
        self.micButton.setImage(muteImage, forState: UIControlState.Normal)
    }
    
    func showMicOnButton(){
        let micImage = UIImage(named: "ic_mic_white_48pt")
        self.micButton.setImage(micImage, forState: UIControlState.Normal)
    }
    
    func updateControlsToPlaying(){
        startButton.hidden = true
        stopButton.hidden = false
        timerLabel.hidden = false
        micButton.hidden = false
        muteButton.hidden = false
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
        }
    }
    

    
    func settingsUpdated(controller: TimerSettingsTableViewController, settings: TimerSettings?){
        if(settings != nil){
            print("settings not nil")
            self.userSettings = settings!
        }
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

//ezaudio stuff
extension TimerViewController{
    
    func startAudio()
    {
        if let plot = self.plot{
            plot.backgroundColor = UIColor.blackColor()
            plot.color = UIColor.loathingColor()
            plot.plotType = EZPlotType.Rolling
            plot.alpha = 0.5
            plot.shouldFill = true;
            plot.shouldMirror = true;
        }
        
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
        
        
        setMicrophone()
        self.microphone.delegate = self
        self.microphone.output = ReverbOutput.sharedOutput()
        self.fft = EZAudioFFTRolling.fftWithWindowSize(FFTViewControllerFFTWindowSize, sampleRate: Float(self.microphone.audioStreamBasicDescription().mSampleRate), delegate: self)
        
        do{
            try session!.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        }
        catch _{
            NSLog("Error setting up audio session active");
        }
        
        if(userSettings.useAudioReverb()){
            startMicrophonePassthrough()
        }
        
        toggleBackgroundSoundEffects()
    }
    
    func stopMicrophonePassthrough(){
        EZOutput.sharedOutput().stopPlayback()
        EZMicrophone.sharedMicrophone().stopFetchingAudio()
    }
    
    func startMicrophonePassthrough(){
        self.microphone.startFetchingAudio()
        //  EZMicrophone.sharedMicrophone().startFetchingAudio()
        EZOutput.sharedOutput().startPlayback();
        backgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
    }
    
    //EZMicrophoneDelegate
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        self.fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.plot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
    
    func setMicrophone(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioRouteChangeListenerCallback:", name: AVAudioSessionRouteChangeNotification, object: nil)

        print("****************\(EZAudioDevice.inputDevices().count) inputDevices***************")
        print(EZAudioDevice.inputDevices())
        
        self.microphone = EZMicrophone.sharedMicrophone()
        //self.microphone = EZMicrophone()
//        //self.microphone.device = EZAudioDevice.inputDevices().last as! EZAudioDevice
//
//        for device in EZAudioDevice.inputDevices() {
//            let d = device as! EZAudioDevice
//            print("device.name \(d.name)")
//            if d.name == "Headset Microphone"{
//                print("set mic to =Headset Microphone")
//                self.microphone.device = d
//            }
//        }

        
       
        
        //print("----------")
        //print(EZAudioDevice.inputDevices().first)
        //print("****************outputDevices***************")
        //print(EZAudioDevice.outputDevices())
        
        let possibleInputs = self.session?.availableInputs
        
        //self.session?.setInputDataSource(AVAudioSessionDataSourceDescription.) = AVAudioSessionPortDescription.
        print("^^^^^^^^^^^^^^^^^^^^^^^ possibleInputs \(possibleInputs) ^^^^^^^^^^^^^^^^^^")
        
//        for input in possibleInputs!{
//            print("input.dataSourceName \(input.portType)")
//            if(input.portType == "MicrophoneWired"){
//                print("we have a MicrophoneWired")
//                AVAudioSessionPortDescription *port = [[[session currentRoute] inputs] firstObject];
//                AVAudioSessionDataSourceDescription *dataSource = [session inputDataSource];
//                EZAudioDevice *device = [[EZAudioDevice alloc] init];
//                device.port = port;
//                device.dataSource = dataSource;
//                return device;
                
                //let mic = EZAudioDevice()
 //               mic.port = input
                //print("input.dataSources = \(input.dataSources)")
                //let mic.dataSource = input.dataSources
                //return input
//            }
//        }
        
//        if(EZAudioDevice.inputDevices().count > 0){
//            //do some work to get get the right mic
//            let currentInput = EZAudioDevice.inputDevices().last as! EZAudioDevice
//            self.microphone.device = currentInput
//            
//        }
    }
    
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        
        
        let maxFrequency: Float = fft.maxFrequency
        let gain = fft.maxFrequencyMagnitude
        let noteName: String = EZAudioUtilities.noteNameStringForFrequency(maxFrequency, includeOctave: true)
//        dispatch_async(dispatch_get_main_queue(), {() -> Void in
//            //NSLog("Highest Note: \(noteName),\nFrequency: \(maxFrequency) amplitude: \(gain)")
//            self.backgroundVisualization.changeSize(min(4,Double(gain * 20)))
//            let color = UIColor(hue: CGFloat(min(1.0,maxFrequency/3000)), saturation: 1.0, brightness: 1.0, alpha: 1.0)
//            //print("alpha = \(CGFloat(1.0 / Double(gain * 10)))")
//            self.backgroundVisualization.changeColor(color)
//        })
    }
    
    func audioRouteChangeListenerCallback (notif: NSNotification){
        let userInfo:[NSObject:AnyObject] = notif.userInfo!
       //print("**************** inputDevices\(EZAudioDevice.inputDevices()) ***************")
       // print("~~~~~~~~~userInfo: \(userInfo) ~~~~~~~~~~")
        let routChangeReason = UInt((userInfo[AVAudioSessionRouteChangeReasonKey]?.integerValue)!)
        switch routChangeReason {
        case AVAudioSessionRouteChangeReason.NewDeviceAvailable.rawValue:
            print("Headphone/Line plugged in");
            break;
            
        case AVAudioSessionRouteChangeReason.OldDeviceUnavailable.rawValue:
            //If the headphones was pulled move to speaker
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            } catch _ {
            }
            print("Headphone/Line was pulled. Stopping player....");
            break;
            
        case AVAudioSessionRouteChangeReason.CategoryChange.rawValue:
            // called at start - also when other audio wants to play
            print("AVAudioSessionRouteChangeReasonCategoryChange");
            break;
        default:
            print("else default \(routChangeReason)")
            break;
        }
    }
}

//Metal State Picker Integration
extension TimerViewController{
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        if  self.meditation!.hasNotStarted() {
            next.animator!.presenting = true
            return mentalStatePresentation
        } else {
            return nil
        }
    }
    
    func mentalStateSelected(picker: MentalStateViewController, didPickState state: String?, color: UIColor?) {
        guard let mediation = self.meditation else{
            return
        }
        
        if let mentalState = state {
            if mediation.hasNotStarted() {
                mediation.mentality_before = mentalState
                //mediation.time_start = NSDate()
            } else if(mediation.inProgress()){
                mediation.mentality_after = mentalState
                mediation.time_end = NSDate()
                History.append(meditation!)
            }
        }
    }
    
    func navigateToNextViewController(){
        self.tabBarController?.selectedIndex = 2
    }
    
    func navigateToHomeViewController(){
        self.tabBarController?.selectedIndex = 0
    }
    
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if self.meditation!.hasEnded() {
            //navigate away to history view nowxs
            navigateToNextViewController()
            self.meditation = nil
        }
        else if meditation!.hasNotStarted(){
            beginMediation()
        }
        
        return nil
    }
    
    func presentation() {
        let storyBoard = UIStoryboard(name: "mental_state", bundle: nil)
        next = storyBoard.instantiateViewControllerWithIdentifier("MentalStateViewController") as! MentalStateViewController
        next.animator = animator
        next.modalPresentationStyle = .Custom
        next.delegate = self
        next.transitioningDelegate = self
        if meditation!.hasNotStarted() {
            next.second = true
        }
        self.presentViewController(next, animated: true, completion: nil)
        mentalStatePresentation = MentalStatePresentation(presentedViewController: next, presentingViewController: self)
    }
    
}
