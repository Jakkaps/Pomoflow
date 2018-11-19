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
class AppDelegate: NSObject, NSApplicationDelegate {

    
    @IBOutlet weak var timeItem: NSMenuItem!
    @IBOutlet weak var startStopItem: NSMenuItem!
    @IBOutlet weak var pauseContinueItem: NSMenuItem!
    @IBOutlet weak var prefsItem: NSMenuItem!
    
    @IBOutlet weak var menu: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    var pomodoroLength = 25
    var workLength = 120
    var breakLength = 5
    
    var remainingTimeSession = 0
    var remainingTimeWork = 0
    
    var onBreak = false
    var started = false
    var isPaused = false

    var workTimer: Timer?
    var pomodoroBreakTimer: Timer?
    
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
            
        }
        
        setTimesFromPreferences()
        resetMenu()
        listenForPrefsChanged()
        timeItem.title = stringToEncourageWork
        statusItem.menu = menu
    }
    
    func setTimesFromPreferences(){
        let currentTimer = prefs.returnSelectedTimer()
        workLength = currentTimer.workLength
        pomodoroLength = currentTimer.pomodoroLength
        breakLength = currentTimer.breakLength
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApp.terminate(NSApp)
    }
    
    fileprivate func resetMenu() {
        let icon = NSImage(named: "statusIcon")
        statusItem.image = icon
        timeItem.title = stringToEncourageWork
        startStopItem.title = "Start"
        pauseContinueItem.isEnabled = false
        
        onBreak = false
        isPaused = false
        
        //First you have to remove the old presets
        for item in menu.items{
            if item.tag == 1{
                menu.removeItem(item)
            }
        }
        
        let timers = prefs.returnAllTimers()
        //Start insering the items 4 steps into the menu
        var menuPositionToInsertAt = 5
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
        let newlySelectedPresetIndex = menu.index(of: sender) - 5
        prefs.selected = newlySelectedPresetIndex
        prefs.save()
        resetMenu()
        setTimesFromPreferences()
    }
    
    func listenForPrefsChanged(){
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil, queue: nil) {
                                                (notification) in
                                                self.workTimer?.invalidate()
                                                self.pomodoroBreakTimer?.invalidate()
                                                self.prefs = Preferences()
                                                print(self.prefs.selected)
                                                self.setTimesFromPreferences()
                                                self.resetMenu()
                                                
        }
    }
    
    @IBAction func startStopClicked(_ sender: Any) {
        if !started {
            startTimers(sessionTime: pomodoroLength, workTime: workLength)
            pauseContinueItem.isEnabled = true
            startStopItem.title = "Stop"
            started = true
            
            for item in menu.items{
                if item.tag == 1{
                    menu.removeItem(item)
                }
            }
        }else{
            if remainingTimeSession <= 0 {
                startXEndOfSessionClicked()
            }else {
                started = false
                pomodoroBreakTimer?.invalidate()
                workTimer?.invalidate()
                resetMenu()
            }
        }
    }
    
    @IBAction func pauseContinueClicked(_ sender: Any) {
        if !isPaused {
            pomodoroBreakTimer?.invalidate()
            workTimer?.invalidate()
            startStopItem.isEnabled = false
            pauseContinueItem.title = "Continue"
        }else{
            startStopItem.isEnabled = true
            startTimers(sessionTime: remainingTimeSession, workTime: remainingTimeWork)
            pauseContinueItem.title = "Pause"
        }
        
        isPaused = !isPaused
    }
    
    
    func endOfSessionReached(){
        let whatToStart = (onBreak ? "pomodoro" : "break")
        startStopItem.title = "Start \(whatToStart)"
        sendNotification(title: "Time for a \(whatToStart)", withSound: false)
    }
    
    func endOfWorkSessionReached(){
        workTimer?.invalidate()
        pomodoroBreakTimer?.invalidate()
        startStopClicked(self)
        sendNotification(title: "YOU ARE DONE", withSound: true)
    }
    
    func startXEndOfSessionClicked(){
        remainingTimeSession = (onBreak ? pomodoroLength : breakLength)
        startStopItem.title = "Stop"
        self.onBreak = !self.onBreak
        updateTimeItem()
    }
    
    private func updateTimeItem(){
        self.timeItem.title = "\(remainingTimeSession >= 0 ? remainingTimeSession : 0)m : \(PomoflowTimer.returnAsHours(min: self.remainingTimeWork))"
    }
    
    @objc func startTimers(sessionTime: Int, workTime: Int){
        statusItem.image = NSImage(named: "statusIconRunning")
        
        remainingTimeWork = workTime
        remainingTimeSession = sessionTime
        
        updateTimeItem()
        
        startBreakPomdoroTimer(sessionTime: remainingTimeSession)
        startWorkTimer(workTime: remainingTimeWork)
    }
    
    func startBreakPomdoroTimer(sessionTime: Int){
        remainingTimeSession = sessionTime
        pomodoroBreakTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            self.remainingTimeSession -= 1
            self.updateTimeItem()
            
            if self.remainingTimeSession == 0 {
                self.endOfSessionReached()
            }
        }
    }
    
    func startWorkTimer(workTime: Int){
        remainingTimeWork = workTime
        workTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            self.remainingTimeWork -= 1
            self.updateTimeItem()
            
            if self.remainingTimeWork == 0 {
                self.endOfWorkSessionReached()
            }
        }
    }
    
    func sendNotification(title: String, withSound: Bool){
        if #available(OSX 10.14, *) {
            let content = UNMutableNotificationContent()
            content.title = title
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
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

