//
//  AppDelegate.swift
//  Pomoflow
//
//  Created by Jens Amund on 11/10/2018.
//  Copyright © 2018 Jakkaps. All rights reserved.
//

import Cocoa
import UserNotifications


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, PomoflowTimerDelegate{
    
    @IBOutlet weak var timeItem: NSMenuItem!
    @IBOutlet weak var startStopItem: NSMenuItem!
    @IBOutlet weak var skipItem: NSMenuItem!
    @IBOutlet weak var pauseContinueItem: NSMenuItem!
    @IBOutlet weak var prefsItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    @IBOutlet weak var menu: NSMenu!
    
    var currentTimer : PomoflowTimer!
    var stringToEncourageWork = "Ya not working"
    var prefs = Preferences()
    var active = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if #available(OSX 10.14, *) {
            let center = UNUserNotificationCenter.current()
            
            // Fallback on earlier versions
            // Request permission to display alerts and play sounds.
            center.requestAuthorization(options: [.alert, .sound])
            { (granted, error) in
                // Enable or disable features based on authorization.
            }
            
            //Action
            let startNext = UNNotificationAction(identifier: "Start", title: "Start", options: .foreground)
            
            //Category
            let invitationCategory = UNNotificationCategory(identifier: "TIMER", actions: [startNext], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
            
            //Register the app’s notification types and the custom actions that they support.
            center.setNotificationCategories([invitationCategory])
            
            center.delegate = self
            
        }
        
        
        currentTimer = prefs.returnSelectedTimer()
        resetMenu()
        listenForPrefsChanged()
        statusItem.menu = menu
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApp.terminate(NSApp)
    }
    
    fileprivate func resetMenu() {
        let icon = NSImage(named: "statusIcon")
        statusItem.image = icon

        timeItem.title = stringToEncourageWork
        
        skipItem.isEnabled = false
        pauseContinueItem.isEnabled = false
        changeDisplayedTimers()
    }
    
    @objc func differentPresetSelcted(sender: NSMenuItem){
        let newlySelectedPresetIndex = menu.index(of: sender) - 5
        prefs.selected = newlySelectedPresetIndex
        prefs.save()
        resetMenu()
        currentTimer.stop()
        currentTimer = prefs.returnSelectedTimer()
        changeDisplayedTimers()
    }
    
    func listenForPrefsChanged(){
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil, queue: nil) {
                                                (notification) in
                                                self.prefs = Preferences()
                                                self.currentTimer.stop()
                                                self.resetMenu()
                                                self.changeDisplayedTimers()
                                                
        }
    }
    
    func changeDisplayedTimers(){
        menu.insertItem(NSMenuItem.separator(), at: 5)
        
        //First you have to remove the old presets
        for item in menu.items{
            if item.tag == 1{
                menu.removeItem(item)
            }
        }
        
        let timers = prefs.returnAllTimers()
        //Start insering the items 4 steps into the menu
        var menuPositionToInsertAt = 6
        for (index, timer) in timers.enumerated() {
            let name = "\(index + 1): \(PomoflowTimer.returnAsHours(min: timer.workLength))/\(timer.pomodoroLength)m/\(timer.breakLength)m"
            let menuItem = NSMenuItem(title: name, action: #selector(differentPresetSelcted(sender:)), keyEquivalent: "")
            
            //All presets have this tag so they can be easily removed
            menuItem.tag = 1
            
            if index == prefs.selected{
                menuItem.state = .on
            }
            
            menu.insertItem(menuItem, at: menuPositionToInsertAt)
            
            menuPositionToInsertAt += 1
        }
        menu.insertItem(NSMenuItem.separator(), at: menuPositionToInsertAt)
    }
    
    @IBAction func startStopClicked(_ sender: Any) {
        if !active {
            currentTimer.delegate = self
            currentTimer.start()
            timeItem.title = "\(currentTimer.pomodoroLength) : \(currentTimer.workLength)"
            statusItem.image = NSImage(named: "statusIconRunning")
            skipItem.isEnabled = true
            pauseContinueItem.isEnabled = true
    
        }else{
            currentTimer.stop()
            resetMenu()
        }
        
        active = !active
    }
    
    @IBAction func pauseContinueClicked(_ sender: Any) {
        
    }
    
    @IBAction func skipClicked(_ sender: Any) {
        
    }
    
    func workFinished() {
        sendNotification(title: "Donezoo", withSound: true)
    }
    
    func pomodoroFinished() {
        sendNotification(title: "Time for a break!", withSound: false)
    }
    
    func breakFinished() {
        sendNotification(title: "Time for work yo!", withSound: false)
    }
    
    
    func updateRemaingTime(workTime: Int, pomodoroOrBreakTime: Int) {
        timeItem.title = "\(pomodoroOrBreakTime) : \(workTime)"
    }
    
    func sendNotification(title: String, withSound: Bool){
        
        if #available(OSX 10.14, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.categoryIdentifier = "TIMER"
            if withSound{
                content.sound = UNNotificationSound.default
            }
            
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @available(OSX 10.14, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        switch response.notification.request.content.categoryIdentifier
        {
        case "TIMER":
            if response.actionIdentifier == "Start"{
                
            }
            
        default:
            break
        }
        completionHandler()
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

