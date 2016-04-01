//
//  StarsOverlay.swift
//  conscious
//
//  Created by William Johnson on 3/18/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//
import UIKit

class StarsOverlay: UIView {
    var origColor: UIColor? = UIColor.whiteColor()
    
    override class func layerClass() -> AnyClass {
        return CAEmitterLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private var emitter: CAEmitterLayer {
        return layer as! CAEmitterLayer
    }
    
    private var particle: CAEmitterCell!
    
    func setup() {
        emitter.emitterMode = kCAEmitterLayerVolume
        emitter.emitterShape = kCAEmitterLayerPoint
        emitter.renderMode = kCAEmitterLayerOldestFirst
        //kCAEmitterLayerAdditive
        
        emitter.preservesDepth = true
        
        particle = CAEmitterCell()
        
        particle.contents = UIImage(named: "spark")!.CGImage
        particle.birthRate = 5
        particle.name = "spark"
        
        particle.lifetime = 10
        particle.lifetimeRange = 50
        
        particle.velocity = 12
        particle.velocityRange = 10
        
        particle.scale = 0.42
        particle.scaleRange = 0.9
        particle.scaleSpeed = 0.9
        particle.color = origColor!.CGColor
        
        particle.alphaRange = 1.0
        particle.redSpeed = 0.0
        particle.blueSpeed = 0.0
        particle.alphaSpeed = -0.5
        
        
        emitter.emitterCells = [particle]
    }
    
    func degreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
    
    var emitterTimer: NSTimer?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if self.window != nil {
            if emitterTimer == nil {
                emitterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "lessRandom", userInfo: nil, repeats: true)
            }
        } else if emitterTimer != nil {
            emitterTimer?.invalidate()
            emitterTimer = nil
        }
    }
    
    func setEmitters(value: Bool, spin: Double? = 130.0) {
        if value == true {
            let zeroDegreesInRadians = degreesToRadians(0.0)
            particle.spin = degreesToRadians(spin!)
            particle.spinRange = zeroDegreesInRadians
            particle.emissionRange = degreesToRadians(360.0)
            emitterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "lessRandom", userInfo: nil, repeats: true)
        } else {
            emitterTimer?.invalidate()
        }
    }
    
    func lessRandom() {
        let sizeWidth = max(bounds.width/4, bounds.height/4)
        let radius = CGFloat(arc4random()) % sizeWidth*4
        emitter.emitterSize = CGSize(width: 10, height: 10)
        particle.birthRate = 10 + sqrt(Float(radius))
    }
    
    
    func changeColor(color: UIColor?) {
        emitter.setValue(color!.CGColor, forKeyPath: "emitterCells.spark.color")
    }
    
    func changeSize(scale: Double) {
        emitter.setValue(scale, forKeyPath: "emitterCells.spark.scale")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitter.emitterPosition = self.center
        emitter.emitterSize = self.bounds.size
    }
}
