//
//  PreferencesViewController.swift
//  Pomoflow
//
//  Created by Jens Amund on 27/10/2018.
//  Copyright © 2018 Jakkaps. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    
    @IBOutlet var presetsPopUp: NSPopUpButton!
    @IBOutlet var workLengthSlider: NSSlider!
    @IBOutlet var pomdoroLengthSlider: NSSlider!
    @IBOutlet var breakLengthSlider: NSSlider!
    
    
    var prefs = Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCurrentPrefs()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showCurrentPrefs(){
        let timers = prefs.returnAllTimers()
        
        for (index, timer) in timers.enumerated(){
            presetsPopUp.insertItem(withTitle: "\(index + 1): \(PomoflowTimer.returnAsHours(min: timer.workLength))/\(timer.pomodoroLength)m/\(timer.breakLength)m", at: index)
        }
        
        presetsPopUp.selectItem(at: prefs.selected)
        updateSlidersForCurrentTimer()
    }
    
    func cleanPopUp(){
        for menuItem in presetsPopUp.itemArray {
            if menuItem.title != "New" && menuItem.title != "Seperator" && menuItem.title != "Delete"{
                presetsPopUp.removeItem(withTitle: menuItem.title)
            }
        }
    }
    
    @IBAction func popUpValueChanged(_ sender: Any) {
        prefs.selected = presetsPopUp.indexOfSelectedItem
        updateSlidersForCurrentTimer()
    }
    
    @IBAction func workLengthSliderChanged(_ sender: Any) {
        //Every tick is fifteen minutes
        prefs.setWorkLengthCurrentTimer(workLength: workLengthSlider.integerValue * 15)
        updateCurrentTitle()
    }
    
    @IBAction func pomodoroLengthSliderChanged(_ sender: Any) {
        prefs.setPomodoroLengthCurrentTimer(pomdoroLength: pomdoroLengthSlider.integerValue)
        updateCurrentTitle()
    }
    
    @IBAction func breakLengthSliderChanged(_ sender: Any) {
        prefs.setBreakLengthCurrentTimer(breakLength: breakLengthSlider.integerValue)
        updateCurrentTitle()
    }
    
    func updateCurrentTitle(){
        let timer = prefs.returnSelectedTimer()
        presetsPopUp.selectedItem?.title = "\(prefs.selected + 1): \(PomoflowTimer.returnAsHours(min: timer.workLength))/\(timer.pomodoroLength)m/\(timer.breakLength)m"
    }
    
    func updateSlidersForCurrentTimer(){
        let currentTimer = prefs.returnSelectedTimer()
        workLengthSlider.integerValue = currentTimer.workLength / 15
        pomdoroLengthSlider.integerValue = currentTimer.pomodoroLength
        breakLengthSlider.integerValue = currentTimer.breakLength
    }
    
    
    
    @IBAction func newButtonClicked(_ sender: Any) {
        //Prefs automatically sets its selected variable to the newly added pomodoflowTimer
        prefs.addTimer(PomoflowTimer(workLength: 0, pomodoroLength: 0, breakLength: 0))
        cleanPopUp()
        showCurrentPrefs()
    }
    @IBAction func deleteButtonClicked(_ sender: Any) {
        //Just looks better when the delete button isn´t in focus
        presetsPopUp.selectItem(at: prefs.selected)
        
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to delete this preset?"
        alert.informativeText = "This action cannot be undone"
        alert.alertStyle = .warning
        
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            prefs.removeTimer(at: prefs.selected)
            cleanPopUp()
            showCurrentPrefs()
        }
    }
    
    @IBAction func okButtonClicked(_ sender: Any) {
        prefs.save()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                        object: nil)
        view.window?.close()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        view.window?.close()
    }
}
