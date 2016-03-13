//
//  TimerSettingsTableViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/6/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit


protocol TimerSettingsTableViewControllerDelegate : class {
    func settingsUpdated(controller: TimerSettingsTableViewController, settings: TimerSettings)
}

class TimerSettingsTableViewController: UITableViewController, SelectableSettingViewControllerDelegate {

    @IBOutlet weak var timePicker: TimePickerView!
    var settings = TimerSettings.getCurrentSettings()
    var settingToUpdate: TimerSettings.SettingType?
    var delegate: TimerSettingsTableViewControllerDelegate?
    
    @IBOutlet weak var selectedNotificationSoundLabel: UILabel!
    @IBOutlet weak var selectedBackgroundSoundLabel: UILabel!
    override func viewDidLoad() {
        timePicker.settings = settings
        updateSelectedSettings()
        
        dispatch_async(dispatch_get_main_queue(),{
            self.timePicker.countDownDuration = self.settings.intervalSeconds
        })
    }
    
    func updateSelectedSettings(){
        selectedNotificationSoundLabel.text = settings.reminderTone
        print("YOYOY settings.backgroundSoundFile = \(settings.backgroundSoundFile)")
        selectedBackgroundSoundLabel.text = settings.backgroundSoundFile
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            print("now call notify the mediation delegate that the settings have changed")
            self.delegate?.settingsUpdated(self, settings: self.settings)
        }
    }
    

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row == 1){
            print("showChangeSettingScreen")
            settingToUpdate = TimerSettings.SettingType.ReminderTone
            self.performSegueWithIdentifier("changeSound", sender: self)
        }else{
            self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
        print("Selected row \(indexPath.row)")
    }
    
    func settingSelected(controller: SelectableSettingViewController, setting: AnyObject, type: TimerSettings.SettingType){
        print("delegate settingSelected called")
        if(type == TimerSettings.SettingType.ReminderTone){
            self.settings.reminderTone = setting as! String
        }
        updateSelectedSettings()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if let navController = segue.destinationViewController as? UINavigationController {
            
            let rootViewController = navController.viewControllers.first as! SelectableSettingViewController
            rootViewController.delegate = self
            if(settingToUpdate == TimerSettings.SettingType.ReminderTone){
                rootViewController.settings = reminderToneSettings()
            }
            
        }
        
    }
    
    func reminderToneSettings() -> [SimpleSelectableSetting]{
        let options = settings.reminderTones
        var soundSettings = [SimpleSelectableSetting]()
        for option in options{
            let simpleSetting = SimpleSelectableSetting(value: option, label: option, selected: (option == settings.reminderTone), type: TimerSettings.SettingType.ReminderTone, onSelect: { (newValue) -> () in
                print(self.settings.reminderTone)
                self.settings.reminderTone = newValue as! String
                self.settings.playReminderTone()
            })
            soundSettings.append(simpleSetting)
        }
        return soundSettings
    }
   
}
