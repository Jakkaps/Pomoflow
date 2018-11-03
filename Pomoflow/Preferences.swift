//
//  File.swift
//  Pomoflow
//
//  Created by Jens Amund on 25/10/2018.
//  Copyright © 2018 Jakkaps. All rights reserved.
//

import Foundation

struct Preferences {
    var timePresets: [PomoflowTimer]
    var selected: Int
    
    init() {
        if let loadedData = UserDefaults.standard.data(forKey: "timePresets"){
            timePresets = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [PomoflowTimer] ?? [PomoflowTimer]()
        }else{
            timePresets = [PomoflowTimer]()
        }

        selected = UserDefaults.standard.integer(forKey: "selected")
        
        if timePresets.isEmpty{
            timePresets.append(PomoflowTimer(workLength: 120, pomodoroLength: 25, breakLength: 5))
        }
    }
    
    func returnSelectedTimer() -> PomoflowTimer{
        return (timePresets.isEmpty ? PomoflowTimer(workLength: 0, pomodoroLength: 0, breakLength: 0): timePresets[selected])
    }
    
    func returnAllTimers() -> [PomoflowTimer] {
        return timePresets
    }
    
    mutating func addTimer(_ timer: PomoflowTimer){
        timePresets.append(timer)
        selected = timePresets.count - 1
    }
    
    mutating func removeTimer(at index: Int){
        timePresets.remove(at: index)
        selected = (selected == 0 ? 0 : selected - 1)
    }
    
    mutating func setWorkLengthCurrentTimer(workLength: Int){
        timePresets[selected].workLength = workLength
    }
    
    mutating func setPomodoroLengthCurrentTimer(pomdoroLength: Int){
        timePresets[selected].pomodoroLength = pomdoroLength
    }
    
    mutating func setBreakLengthCurrentTimer(breakLength: Int){
        timePresets[selected].breakLength = breakLength
    }


    
    func save(){
        let data = NSKeyedArchiver.archivedData(withRootObject: timePresets)
        
        UserDefaults.standard.set(data, forKey: "timePresets")
        UserDefaults.standard.set(selected, forKey: "selected")
    }
}
