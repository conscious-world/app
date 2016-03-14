//
//  MediaViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/4/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import AVFoundation

class MediaViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    var audioPlayer:AVAudioPlayer!
    var minValue: NSTimeInterval!
    var maxValue: NSDate?
    var timer = NSTimer()
    var duration: Double?
    var playing: Bool = false
    var mediation: Meditation?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAudio()
        playPauseButton.setImage(UIImage(named: "video-player-7"), forState: UIControlState.Normal)
        playPauseButton.backgroundColor = UIColor.blueColor()

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
        // this resets regardless of scrub
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
