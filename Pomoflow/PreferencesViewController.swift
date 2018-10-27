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
    }
    
    func showCurrentPrefs(){
        let timers = prefs.returnAllTimers()
        
        for (index, timer) in timers.enumerated(){
            presetsPopUp.insertItem(withTitle: "\(index + 1): \(timer.workLength)/\(timer.pomodoroLength)/\(timer.breakLength)", at: index)
        }
        
        presetsPopUp.selectItem(at: prefs.selected)
        updateSlidersForCurrentTimer()
    }
    
    func cleanPopUp(){
        for menuItem in presetsPopUp.itemArray {
            if menuItem.title != "New" && menuItem.title != "Seperator"{
                presetsPopUp.removeItem(withTitle: menuItem.title)
            }
        }
    }
    
    @IBAction func popUpValueChanged(_ sender: Any) {
        prefs.selected = presetsPopUp.indexOfSelectedItem
        print(prefs.selected)
        updateSlidersForCurrentTimer()
    }
    
    @IBAction func workLengthSliderChanged(_ sender: Any) {
        prefs.setWorkLengthCurrentTimer(workLength: workLengthSlider.integerValue)
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
        presetsPopUp.selectedItem?.title = "\(prefs.selected + 1): \(timer.workLength)/\(timer.pomodoroLength)/\(timer.breakLength)"
    }
    
    func updateSlidersForCurrentTimer(){
        let currentTimer = prefs.returnSelectedTimer()
        workLengthSlider.integerValue = currentTimer.workLength
        pomdoroLengthSlider.integerValue = currentTimer.pomodoroLength
        breakLengthSlider.integerValue = currentTimer.breakLength
    }
    
    @IBAction func newButtonClicked(_ sender: Any) {
        //Prefs automatically sets its selected variable to the newly added pomodoflowTimer
        prefs.addTimer(PomoflowTimer(workLength: 0, pomodoroLength: 0, breakLength: 0))
        cleanPopUp()
        showCurrentPrefs()
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
