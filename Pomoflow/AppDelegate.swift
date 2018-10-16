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

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let timeItem = NSMenuItem(title: "Ya not working", action: nil, keyEquivalent: "");
    let startStopItem = NSMenuItem(title: "Start", action: #selector(AppDelegate.startTimerClicked), keyEquivalent: "s")
    let pauseContinueItem: NSMenuItem = NSMenuItem(title: "Pause", action: nil, keyEquivalent: "p")
    
    let sessionLength = 10
    let workLength = 20
    let breakLength = 5
    
    var remainingTimeSession = 0
    var remainingTimeWork = 0
    var onBreak = false

    var timer: Timer?
    

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
        
        constructDefaultMenu(nil)
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
            
            print(title)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func resetMenu(){
        timeItem.title = "Ya not working"
        startStopItem.title = "Start"
        startStopItem.action = #selector(startTimerClicked)
        pauseContinueItem.action = nil
    }
    
    @objc func startTimerClicked(){
        startTimer(sessionTime: sessionLength, workTime: workLength)
        startStopItem.title = "Stop"
        startStopItem.action = #selector(stopTimerClicked)
    }
    
    @objc func stopTimerClicked(){
        timer?.invalidate()
        resetMenu()
    }
    
    @objc func continueTimerClicked(){
        startTimer(sessionTime: remainingTimeSession, workTime: remainingTimeWork)
        pauseContinueItem.title = "Pause"
        
        if(remainingTimeSession > 0){
            startStopItem.title = "Stop"
            startStopItem.action = #selector(stopTimerClicked)
        }else{
            let whatToStart = (onBreak ? "pomdoro" : "break")
            startStopItem.title = "Start \(whatToStart)"
            startStopItem.action = #selector(startXEndOfSessionClicked)
        }
    }
    
    @objc func pauseTimerClicked(){
        timer?.invalidate()
        startStopItem.action = nil
        pauseContinueItem.title = "Continue"
        pauseContinueItem.action = #selector(continueTimerClicked)
    }
    
    @objc func endOfSessionReached(){
        let whatToStart = (onBreak ? "pomodoro" : "break")
        startStopItem.title = "Start \(whatToStart)"
        startStopItem.action = #selector(startXEndOfSessionClicked)
        sendNotification(title: "Time for a \(whatToStart)", withSound: false)
    }
    
    func endOfWorkSessionReached(){
        timer?.invalidate()
        resetMenu()
        sendNotification(title: "YOU ARE DONE", withSound: true)
    }
    
    @objc func startXEndOfSessionClicked(){
        remainingTimeSession = (onBreak ? sessionLength : breakLength)
        startStopItem.title = "Stop"
        startStopItem.action = #selector(stopTimerClicked)
        self.onBreak = !self.onBreak
    }
    
    @objc func startTimer(sessionTime: Int, workTime: Int){
        remainingTimeSession = sessionTime
        remainingTimeWork = workTime
        
        self.timeItem.title = "\(remainingTimeSession >= 0 ? remainingTimeSession : 0)m : \(remainingTimeWork)m"
        pauseContinueItem.action = #selector(pauseTimerClicked)
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
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
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func constructDefaultMenu(_ sender:Any?) {
        let menu = NSMenu()
        
        menu.addItem(timeItem)
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(startStopItem)
        menu.addItem(pauseContinueItem)
    
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem(title: "Quit Pomoflow", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
}

