//
//  TimerViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import AudioKit

class TimerViewController: UIViewController, EZMicrophoneDelegate {
    
    var settingButton : UIBarButtonItem?
    
    
    @IBOutlet weak var plot: EZAudioPlotGL?
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    var microphone: EZMicrophone!
    var session: AVAudioSession?
    var backgroundTaskId: UIBackgroundTaskIdentifier?
    
    // Particle Visualization
    let statusLabel = UILabel()
    let floatPi = Float(M_PI)
    var gravityWellAngle: Float = 0
    
    var particleLab: ParticleLab!
    var fft: AKFFT!
    var amplitudeTracker: AKAmplitudeTracker!
    var amplitude: Float = 0
    
    var lowMaxIndex: Float = 0
    var hiMaxIndex: Float = 0
    var hiMinIndex: Float = 0

    
    // Status Bar Style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
        session = AVAudioSession.sharedInstance()
        startAudio()
    }
    
    func styleButtons(){
        let btnAttrs = [NSUnderlineStyleAttributeName : 0]
        let startTitleStr = NSMutableAttributedString(string:"▶︎ Begin", attributes:btnAttrs)
        startButton.setAttributedTitle(startTitleStr, forState: .Normal)
        let stopTitleStr = NSMutableAttributedString(string:"◼︎ Stop", attributes:btnAttrs)
        stopButton.setAttributedTitle(stopTitleStr, forState: .Normal)
    }
    
    
    @IBAction func onStopButtonPressed(sender: UIButton) {
//        EZOutput.sharedOutput().stopPlayback()
//        EZMicrophone.sharedMicrophone().stopFetchingAudio()
        sender.hidden = true
        startButton.hidden = false
    }
    
    @IBAction func onStartButtonPressed(sender: UIButton) {
        //startAudio()
        sender.hidden = true
        stopButton.hidden = false
        AudioKit.start()
//        EZMicrophone.sharedMicrophone().startFetchingAudio()
//        EZOutput.sharedOutput().startPlayback();
        backgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        
    }
    
    
    
    func startAudio()
    {
        
        let mic = AKMicrophone()
        
        fft = AKFFT(mic)
        
        amplitudeTracker = AKAmplitudeTracker(mic)
        
        // Turn the volume all the way down on the output of amplitude tracker
        let noAudioOutput = AKMixer(amplitudeTracker)
        noAudioOutput.volume = 0
        
        AudioKit.output = noAudioOutput
        AudioKit.start()
        
        let _ = AKPlaygroundLoop(every: 1 / 60) {
            let fftData = self.fft.fftData
            let count = 250
            
            let lowMax = fftData[0 ... (count / 2) - 1].maxElement() ?? 0
            let hiMax = fftData[count / 2 ... count - 1].maxElement() ?? 0
            let hiMin = fftData[count / 2 ... count - 1].minElement() ?? 0
            
            let lowMaxIndex = fftData.indexOf(lowMax) ?? 0
            let hiMaxIndex = fftData.indexOf(hiMax) ?? 0
            let hiMinIndex = fftData.indexOf(hiMin) ?? 0
            
            self.amplitude = Float(self.amplitudeTracker.amplitude * 25)
            
            self.lowMaxIndex = Float(lowMaxIndex)
            self.hiMaxIndex = Float(hiMaxIndex - count / 2)
            self.hiMinIndex = Float(hiMinIndex - count / 2)
        }
        
        // ----
        
        view.backgroundColor = UIColor.whiteColor()
        
        let numParticles = ParticleCount.HalfMillion
        
        if view.frame.height < view.frame.width
        {
            particleLab = ParticleLab(width: UInt(view.frame.width),
                height: UInt(view.frame.height),
                numParticles: numParticles)
            
            particleLab.frame = CGRect(x: 0,
                y: 0,
                width: view.frame.width,
                height: view.frame.height)
        }
        else
        {
            particleLab = ParticleLab(width: UInt(view.frame.height),
                height: UInt(view.frame.width),
                numParticles: numParticles)
            
            particleLab.frame = CGRect(x: 0,
                y: 0,
                width: view.frame.height,
                height: view.frame.width)
        }
        
        particleLab.particleLabDelegate = self
        particleLab.dragFactor = 0.9
        particleLab.clearOnStep = false
        particleLab.respawnOutOfBoundsParticles = true
        
        view.addSubview(particleLab)
        
        statusLabel.textColor = UIColor.darkGrayColor()
        statusLabel.text = "AudioKit Particles"
        
        view.addSubview(statusLabel)
//        self.plot?.backgroundColor = UIColor(red:11.0/255.0, green: 102.0/255.0, blue: 255.0/255.0, alpha: 1.0);
//        self.plot?.shouldFill = true
//        self.plot?.shouldMirror = true
//        
//        do{
//            try session!.setCategory(AVAudioSessionCategoryPlayAndRecord)
//        }
//        catch _{
//            NSLog("Error setting up audio session category:")
//        }
//        
//        do{
//            try session!.setActive(true)
//        }
//        catch {
//            NSLog("Error setting up audio session active")
//        }
//        
//        
//        
//        EZMicrophone.sharedMicrophone().delegate = self
//        //EZMicrophone.sharedMicrophone().startFetchingAudio()
//        EZMicrophone.sharedMicrophone().output = ReverbOutput.sharedOutput()
//        //EZMicrophone.sharedMicrophone().output = DelayedOutput.sharedOutput()
//        
//        do{
//            try session!.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
//        }
//        catch _{
//            NSLog("Error setting up audio session active");
//            
//        }
        
    }
    func particleLabStep()
    {
        gravityWellAngle = gravityWellAngle + 0.01
        
        let radiusLow = 0.1 + (lowMaxIndex / 256)
        
        particleLab.setGravityWellProperties(gravityWell: .One,
            normalisedPositionX: 0.5 + radiusLow * sin(gravityWellAngle),
            normalisedPositionY: 0.5 + radiusLow * cos(gravityWellAngle),
            mass: (lowMaxIndex * amplitude),
            spin: -(lowMaxIndex * amplitude))
        
        particleLab.setGravityWellProperties(gravityWell: .Four,
            normalisedPositionX: 0.5 + radiusLow * sin((gravityWellAngle + floatPi)),
            normalisedPositionY: 0.5 + radiusLow * cos((gravityWellAngle + floatPi)),
            mass: (lowMaxIndex * amplitude),
            spin: -(lowMaxIndex * amplitude))
        
        let radiusHi = 0.1 + (0.25 + (hiMaxIndex / 1024))
        
        particleLab.setGravityWellProperties(gravityWell: .Two,
            normalisedPositionX: particleLab.getGravityWellNormalisedPosition(gravityWell: .One).x + (radiusHi * sin(gravityWellAngle * 3)),
            normalisedPositionY: particleLab.getGravityWellNormalisedPosition(gravityWell: .One).y + (radiusHi * cos(gravityWellAngle * 3)),
            mass: (hiMaxIndex * amplitude),
            spin: (hiMinIndex * amplitude))
        
        particleLab.setGravityWellProperties(gravityWell: .Three,
            normalisedPositionX: particleLab.getGravityWellNormalisedPosition(gravityWell: .Four).x + (radiusHi * sin((gravityWellAngle + floatPi) * 3)),
            normalisedPositionY: particleLab.getGravityWellNormalisedPosition(gravityWell: .Four).y + (radiusHi * cos((gravityWellAngle + floatPi) * 3)),
            mass: (hiMaxIndex * amplitude),
            spin: (hiMinIndex * amplitude))
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews()
    {
        statusLabel.frame = CGRect(x: 5,
            y: view.frame.height - statusLabel.intrinsicContentSize().height,
            width: view.frame.width,
            height: statusLabel.intrinsicContentSize().height)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    //EZMicrophoneDelegate
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.plot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
//        });
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
    
    func onSettingsBarBtnTap(){
        print("click");
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsViewController  = storyBoard.instantiateViewControllerWithIdentifier("TimerSettingsTableViewController") as? TimerSettingsTableViewController{
            
            self.navigationController?.pushViewController(settingsViewController, animated: true)
        }else{
            print("No vc found")
        }
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

extension TimerViewController: ParticleLabDelegate
{
    func particleLabMetalUnavailable()
    {
        // handle metal unavailable here
    }
    
    func particleLabDidUpdate(status: String)
    {
        statusLabel.text = status
        
    }
}
