//
//  PlayPauseButton.swift
//  conscious
//
//  Created by William Johnson on 3/17/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

public class PlayPauseButton: UIButton {
    
    private var notPlaying: Bool = false
    
    var playImage: UIImage?
    var pauseImage: UIImage?
    var origImage: UIImage!
    var tintedPlay: UIImage!
    var tintedPause: UIImage!
    var tintedImage: UIImage!
    
    /** Contains the button's current value. */
    public var playing: Bool {
        get { return notPlaying }
        set { togglePlaying(playing) }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = tintColor
        
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    



    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func drawRect(rect: CGRect) {
        // Drawing code
        
        
        playImage = UIImage(named: "play_video");
        pauseImage = UIImage(named: "white_pause_button");
        
        tintedPlay = playImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        tintedPause = pauseImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
//        tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//        
        self.backgroundColor = UIColor.clearColor()
        self.setImage(tintedImage, forState: UIControlState.Normal)
        self.setBackgroundImage(tintedPlay, forState: UIControlState.Normal)
        self.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
    }
    
    
    public func togglePlaying(playing: Bool) {
        if playing == true {
            self.setBackgroundImage(tintedPause, forState: UIControlState.Normal)
        } else {
            self.setBackgroundImage(tintedPlay, forState: UIControlState.Normal)
        }
        self.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)

    }

}

