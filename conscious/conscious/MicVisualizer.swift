//
//  StarsOverlay.swift
//  conscious
//
//  Created by William Johnson on 3/18/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//
import UIKit

class MicVisualizer: UIView {
    
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
        emitter.emitterMode = kCAEmitterLayerOutline
        emitter.emitterShape = kCAEmitterLayerCircle
        emitter.renderMode = kCAEmitterLayerOldestFirst
        emitter.preservesDepth = true
        
        particle = CAEmitterCell()
        
        particle.contents = UIImage(named: "spark")!.CGImage
        particle.name = "spark"
        particle.birthRate = 5
        
        particle.lifetime = 10
        particle.lifetimeRange = 5
        
        particle.velocity = 12
        particle.velocityRange = 10
        
        particle.scale = 0.02
        particle.scaleRange = 0.1
        particle.scaleSpeed = 0.02
        
        emitter.emitterCells = [particle]
    }
    
    var emitterTimer: NSTimer?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if self.window != nil {
            if emitterTimer == nil {
                emitterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "randomizeEmitterPosition", userInfo: nil, repeats: true)
            }
        } else if emitterTimer != nil {
            emitterTimer?.invalidate()
            emitterTimer = nil
        }
    }
    
    func randomizeEmitterPosition() {
        let sizeWidth = max(bounds.width, bounds.height)
        let radius = CGFloat(arc4random()) % sizeWidth
        emitter.emitterSize = CGSize(width: radius, height: radius)
        particle.birthRate = 10 + sqrt(Float(radius))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitter.emitterPosition = self.center
        emitter.emitterSize = self.bounds.size
    }
    
    func changeSize(scale: Double) {
        emitter.setValue(scale, forKeyPath: "emitterCells.spark.scale")
    }
    
    func changeColor(color: UIColor) {
        emitter.setValue(color.CGColor, forKeyPath: "emitterCells.spark.color")
    }
}