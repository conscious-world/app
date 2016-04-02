//
//  ProfileViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/31/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import Player

class ProfileViewController: UIViewController, PlayerDelegate {

    @IBOutlet weak var backgroundVideoContainer: UIView!
    let videoNames = ["heavenly-rays", "green-sky-in-space","abstract-ocean-with-light-flares", "lights-sea-sparkling_bynqeb", "stars-and-colors-in-space"]
    var player = Player()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addBackgroundVideo()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.player.playFromBeginning()
        //self.player.fillMode = AVLayerVideoGravityResizeAspectFill
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBackgroundVideo(){
        self.player.delegate = self
        self.player.view.frame = self.view.bounds
        self.addChildViewController(player)
        self.backgroundVideoContainer.addSubview(player.view)
        self.player.didMoveToParentViewController(self)
        
        let urlpath = NSBundle.mainBundle().pathForResource(videoNames[0], ofType: "mp4")
        let videoUrl:NSURL = NSURL.fileURLWithPath(urlpath!)
        self.player.setUrl(videoUrl)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
