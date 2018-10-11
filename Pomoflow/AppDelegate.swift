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
    let menuItem = NSMenuItem(title: "Start Timer", action: #selector(AppDelegate.startTimer(_:)), keyEquivalent: "P")
    
    var time = 25

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        constructMenu()
    }
    
    @objc func startTimer(_ sender: Any){
        menuItem.title = "\(time) minutes remaining"
        menuItem.action = nil
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.time -= 1
            self.menuItem.title = "\(self.time) minutes remaining"
            
            if self.time == 0 {
                timer.invalidate()
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }


}

