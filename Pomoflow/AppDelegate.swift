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
    
    let sessionLength = 10
    let workLength = 100
    let breakLength = 5
    
    var remainingTimeSession = 0
    var remainingTimeWork = 0
    
    var onBreak = false
    var started = false
    var isPaused = false

    var timer: Timer?
    
    var stringToEncourageWork = "Ya not working"

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
        
        timeItem.title = stringToEncourageWork
        statusItem.menu = menu
    }
    
    
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApp.terminate(NSApp)
    }
    
    @IBAction func startStopClicked(_ sender: Any) {
        if !started {
            startTimer(sessionTime: sessionLength, workTime: workLength)
            pauseContinueItem.isEnabled = true
            startStopItem.title = "Stop"
            started = true
        }else{
            if remainingTimeSession <= 0 {
                startXEndOfSessionClicked()
            }else {
                timeItem.title = stringToEncourageWork
                timer?.invalidate()
                startStopItem.title = "Start"
                pauseContinueItem.isEnabled = false
                started = false
            }
        }
    }
    
    @IBAction func pauseContinueClicked(_ sender: Any) {
        if !isPaused {
            timer?.invalidate()
            startStopItem.isEnabled = false
            pauseContinueItem.title = "Continue"
        }else{
            startStopItem.isEnabled = true
            startTimer(sessionTime: remainingTimeSession, workTime: remainingTimeWork)
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
        timer?.invalidate()
        startStopClicked(self)
        sendNotification(title: "YOU ARE DONE", withSound: true)
    }
    
    func startXEndOfSessionClicked(){
        remainingTimeSession = (onBreak ? sessionLength : breakLength)
        startStopItem.title = "Stop"
        self.onBreak = !self.onBreak
    }
    
    @objc func startTimer(sessionTime: Int, workTime: Int){
        remainingTimeSession = sessionTime
        remainingTimeWork = workTime
        
        self.timeItem.title = "\(remainingTimeSession >= 0 ? remainingTimeSession : 0)m : \(remainingTimeWork)m"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.remainingTimeSession -= 1
            self.remainingTimeWork -= 1
            
            self.timeItem.title = "\(self.remainingTimeSession >= 0 ? self.remainingTimeSession : 0)m : \(self.remainingTimeWork)m"
            
            if self.remainingTimeWork == 0 {
                self.endOfWorkSessionReached()
            }
            
            if self.remainingTimeSession == 0 {
                self.endOfSessionReached()
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

