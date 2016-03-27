//
//  GlobalTabBarViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/26/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class GlobalTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the selected icons and text tint color
        self.tabBar.tintColor = UIColor.loathingColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
