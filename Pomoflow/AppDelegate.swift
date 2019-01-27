//
//  AppDelegate.swift
//  Pomoflow
//
//  Created by Jens Amund on 11/10/2018.
//  Copyright © 2018 Jakkaps. All rights reserved.
//

import Cocoa
import UserNotifications

enum State {
    case paused, active, notStarted, waiting
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, PomoflowTimerDelegate{
    
    @IBOutlet weak var timeItem: NSMenuItem!
    @IBOutlet weak var startStopItem: NSMenuItem!
    @IBOutlet weak var skipStartNextItem: NSMenuItem!
    @IBOutlet weak var pauseContinueItem: NSMenuItem!
    @IBOutlet weak var prefsItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    @IBOutlet weak var menu: NSMenu!
    
    var state : State!{
        didSet{
            if let state = state{
                switch state {
                case .paused:
                    skipStartNextItem.isEnabled = false
                    pauseContinueItem.title = "Continue"
                case .active:
                    pauseContinueItem.title = "Pause"
                    skipStartNextItem.title = "Skip"
                    
                    skipStartNextItem.isEnabled = true
                case .waiting:
                    let whatToStart = currentTimer.onBreak ? "Break" : "Pomodoro"
                    skipStartNextItem.title = "Start \(whatToStart)"
                case .notStarted:
                    let icon = NSImage(named: "statusIcon")
                    statusItem.image = icon
                    
                    startStopItem.title = "Start"
                    skipStartNextItem.title = "Skip"
                    timeItem.title = stringToEncourageWork
                    
                    skipStartNextItem.isEnabled = false
                    pauseContinueItem.isEnabled = false
                    changeDisplayedTimers()
                }
            }
        }
    }
    
    var currentTimer : PomoflowTimer!
    var stringToEncourageWork = "Ya not working"
    var prefs = Preferences()

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
        state = .notStarted
        listenForPrefsChanged()
        statusItem.menu = menu
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApp.terminate(NSApp)
    }
    
    @IBAction func skipStartNextClicked(_ sender: Any) {
        if state != .waiting{
            currentTimer.skip()
            state = .waiting
        } else{
            currentTimer.startNext()
            state = .active
        }
    }
    
    @IBAction func startStopClicked(_ sender: Any) {
        if state == .notStarted {
            currentTimer.delegate = self
            currentTimer.start()
            
            statusItem.image = NSImage(named: "statusIconRunning")
            startStopItem.title = "Stop"
            pauseContinueItem.isEnabled = true
            
            state = .active
        } else {
            currentTimer.stop()
            state = .notStarted
        }
    }
    
    @IBAction func pauseContinueClicked(_ sender: Any) {
        if state != .paused{
            currentTimer.pause()
            state = .paused
        }else{
            currentTimer.unPause()
            state = .active
        }
    }
    
    func workFinished() {
        sendNotification(title: "Donezoo", withSound: true)
        state = .notStarted
    }
    
    func pomodoroFinished() {
        sendNotification(title: "Time for a break!", withSound: false)
        state = .waiting
    }
    
    func breakFinished() {
        sendNotification(title: "Time for work yo!", withSound: false)
        state = .waiting
    }
    
    func updateRemaingTime(workTime: Int, pomodoroOrBreakTime: Int) {
        timeItem.title = "\(pomodoroOrBreakTime) : \(workTime)"
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
    
    @objc func differentPresetSelcted(sender: NSMenuItem){
        let newlySelectedPresetIndex = menu.index(of: sender) - 6
        prefs.selected = newlySelectedPresetIndex
        prefs.save()
        state = .notStarted
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
                                                self.state = .notStarted
                                                self.changeDisplayedTimers()
                                                
        }
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

