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
        selectedBackgroundSoundLabel.text = settings.backgroundSoundFile
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            self.settings.stopBackgroundSound()
            self.settings.stopReminderTone()
            self.delegate?.settingsUpdated(self, settings: self.settings)
        }
    }
    

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row == 1){
            settingToUpdate = TimerSettings.SettingType.ReminderTone
            self.performSegueWithIdentifier("changeSound", sender: self)
        }else if(indexPath.row == 2){
            settingToUpdate = TimerSettings.SettingType.BackgroundSoundFile
            self.performSegueWithIdentifier("changeSound", sender: self)
        }
        else{
            self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
    }
    
    func settingSelected(controller: SelectableSettingViewController, setting: AnyObject, type: TimerSettings.SettingType){
        if(type == TimerSettings.SettingType.ReminderTone){
            self.settings.reminderTone = setting as! String
        }else if(type == TimerSettings.SettingType.BackgroundSoundFile){
            self.settings.backgroundSoundFile = setting as! String
        }
        updateSelectedSettings()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if let navController = segue.destinationViewController as? UINavigationController {
            
            let rootViewController = navController.viewControllers.first as! SelectableSettingViewController
            rootViewController.delegate = self
            if(settingToUpdate == TimerSettings.SettingType.ReminderTone){
                rootViewController.settings = reminderToneSettings()
            }else if settingToUpdate == TimerSettings.SettingType.BackgroundSoundFile{
                rootViewController.settings = backgroundSounndSettings()
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
    
    func backgroundSounndSettings() -> [SimpleSelectableSetting]{
        let options = settings.backgroundSoundFiles
        var soundSettings = [SimpleSelectableSetting]()
        for option in options{
            let simpleSetting = SimpleSelectableSetting(value: option, label: option, selected: (option == settings.backgroundSoundFile), type: TimerSettings.SettingType.BackgroundSoundFile, onSelect: { (newValue) -> () in
                print(self.settings.reminderTone)
                self.settings.backgroundSoundFile = newValue as! String
                self.settings.playBackgroundSound()
            })
            soundSettings.append(simpleSetting)
        }
        return soundSettings
    }
   
}
