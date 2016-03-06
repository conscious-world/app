//
//  TimerViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    
    var settingButton : UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
//        
//        let storyboard = UIStoryboard.storyboardWithName("Main", bundle:nil)
//        let vc = [storyboard instantiateViewControllerWithIdentifier:@"TopOverVc"];
//        
//        vc.view.backgroundColor = [UIColor clearColor];
//        self.modalPresentationStyle = UIModalPresentationCurrentContext;
//        [self presentViewController:vc animated:NO completion:nil];
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
