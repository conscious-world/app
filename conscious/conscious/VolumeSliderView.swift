//
//  VolumeSliderView.swift
//  conscious
//
//  Created by William Johnson on 3/17/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit


public class VolumeSliderView: UIView {
    private var defaultValue: Float = 0.5
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var rightSoundImage: UIImageView!
    @IBOutlet weak var leftSoundImage: UIImageView!
    @IBOutlet var sliderView: UIView!
    

    
    var value: Float! {
        get { return defaultValue }
        set { volumeSlider.value = newValue }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        // standard initialization logic
        let nib = UINib(nibName: "VolumeSliderView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        sliderView.backgroundColor = UIColor.clearColor()
        sliderView.frame = bounds
        sliderView.addSubview(volumeSlider)
        addSubview(sliderView)
//        var pan = UIPanGestureRecognizer(target: self, action: "onVolumePan:")
//        volumeSlider!.userInteractionEnabled = true
//        volumeSlider?.addGestureRecognizer(pan)
    }
    
    func onVolumePan(sender: UIPanGestureRecognizer) {
    print("hi!")
    }
    
}
