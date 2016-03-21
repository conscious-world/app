//
//  TiledTriangles.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/19/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class TiledTriangleView: UIView{
    
    var tileWidth: Int = 100
    var tileHeight: Int = 75
    
    var backgroundImage = UIImage(named: "colorGradientsqr")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    init(frame: CGRect, tileWidth: Int, tileHeight: Int) {
        super.init(frame: frame)
        self.tileWidth   = tileWidth
        self.tileHeight = tileHeight
        initSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            subview.removeFromSuperview()
        }
        initSubviews()
    }
    
    private var numAccross: Int{
        get{
            let decimalCountAccross = ceil(self.frame.width / CGFloat(self.tileWidth))
            return Int( decimalCountAccross + 1.0)
        }
    }
    
    private var numDown: Int{
        get{
            let decimalCountDown = ceil(self.frame.height / CGFloat(self.tileHeight))
            return Int( decimalCountDown)
        }
    }
    
    func initSubviews(){
        drawTiles()
    }
    
    func drawTiles(){
        for yindex in 0...numDown{
            for xindex in -1...numAccross {
                let triangleTile = TriangleTile(width: tileWidth, height: tileHeight, xIndex: xindex, yIndex: yindex)
                self.addSubview(triangleTile)
                print("self.center = \(triangleTile.center)")
                let selectionPoint = CGPoint(x: triangleTile.center.x * 0.9, y: triangleTile.center.y * 0.8)
                print("backgroundImage?.getPixelColor(self.center) = \(selectionPoint)")
                triangleTile.backgroundColor = backgroundImage?.getPixelColor(selectionPoint)
            }
        }
        
    }
    

    class TriangleTile: UIView{
        //var DynamicView=UIView(frame: CGRectMake(x, y, 100, 100))
        var width:  Int
        var height: Int
        
        init(width:Int, height:Int, xIndex: Int, yIndex: Int){
            
            let xDelta = CGFloat(width/2)
            let yDelta = CGFloat(height)

            self.width  = width
            self.height = height
            
            let frame = CGRectMake(CGFloat(xIndex) * xDelta, CGFloat(yIndex) * yDelta, CGFloat(width), CGFloat(width))

            super.init(frame: frame)
            
            addTriangleMask(xIndex + yIndex)
            self.alpha = 1.0
            
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var xDelta:CGFloat{
            return CGFloat(width/2)
        }
        
        var yDelta:CGFloat{
            return CGFloat(height)
        }
        
        func addTriangleMask(index:Int){
            
            // Build a triangular path
            
            let path = UIBezierPath()
            
            if(index % 2 == 0){
                path.moveToPoint(CGPoint(x: 0,y: 0))
                path.addLineToPoint(CGPoint(x: xDelta,y: yDelta))
                path.addLineToPoint(CGPoint(x: width,y: 0))
                path.addLineToPoint(CGPoint(x: 0,y: 0))
            }else{
                path.moveToPoint(CGPoint(x: 0,y: yDelta))
                path.addLineToPoint(CGPoint(x: xDelta, y: 0))
                path.addLineToPoint(CGPoint(x: width, y: Int(yDelta)))
                path.addLineToPoint(CGPoint(x: 0,y: yDelta))
            }
            
            
            // Create a CAShapeLayer with this triangular path
            // Same size as the original imageView
            let mask = CAShapeLayer()
            
            mask.frame = self.bounds;
            mask.path = path.CGPath;
            
            // Mask the imageView's layer with this shape
            self.layer.mask = mask;

        }
        
    }
    

}
