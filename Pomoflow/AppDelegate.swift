//
//  AppDelegate.swift
//  Pomoflow
//
//  Created by Jens Amund on 11/10/2018.
//  Copyright © 2018 Jakkaps. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let timeItem = NSMenuItem(title: "Ya not working", action: nil, keyEquivalent: "");
    let startStopItem = NSMenuItem(title: "Start", action: #selector(AppDelegate.startTimerClicked), keyEquivalent: "s")
    let pauseContinueItem: NSMenuItem = NSMenuItem(title: "Pause", action: nil, keyEquivalent: "p")
    
    let sessionLength = 25
    let workLength = 60
    let breakLength = 5
    
    var remainingTimeSession = 0
    var remainingTimeWork = 0

    var timer: Timer?
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        constructDefaultMenu(nil)
    }
    
    @objc func startTimerClicked(){
        startTimer(sessionTime: sessionLength, workTime: workLength)
    }
    
    @objc func stopTimerClicked(){
        timer?.invalidate()
        
        timeItem.title = "Ya not working"
        startStopItem.title = "Start"
        startStopItem.action = #selector(startTimerClicked)
        pauseContinueItem.action = nil
    }
    
    @objc func continueTimerClicked(){
        startTimer(sessionTime: remainingTimeSession, workTime: remainingTimeWork)
        pauseContinueItem.title = "Pause"
    }
    
    @objc func pauseTimerClicked(){
        timer?.invalidate()
        pauseContinueItem.title = "Continue"
        pauseContinueItem.action = #selector(continueTimerClicked)
    }
    
    @objc func startTimer(sessionTime: Int, workTime: Int){
        remainingTimeSession = sessionTime
        remainingTimeWork = workTime
        var onBreak = false
        
        self.timeItem.title = "\(remainingTimeSession)m : \(remainingTimeWork)m"
        startStopItem.title = "Stop"
        startStopItem.action = #selector(stopTimerClicked)
        pauseContinueItem.action = #selector(pauseTimerClicked)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.remainingTimeSession -= 1
            self.remainingTimeWork -= 1
            self.timeItem.title = "\(self.remainingTimeSession)m : \(self.remainingTimeWork)m"
            
            if self.remainingTimeSession == 0 {
                self.remainingTimeSession = (onBreak ? self.sessionLength : self.breakLength)
                onBreak = !onBreak
            }
            
            if self.remainingTimeWork == 0 {
                
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

