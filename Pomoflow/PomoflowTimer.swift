//
//  PomoflowTimer.swift
//  Pomoflow
//
//  Created by Jens Amund on 25/10/2018.
//  Copyright © 2018 Jakkaps. All rights reserved.
//

import Foundation

protocol PomoflowTimerDelegate{
    func workFinished()
    func pomodoroFinished()
    func breakFinished()
    
    func updateRemaingTime(workTime: Int, pomodoroOrBreakTime: Int)
}

class PomoflowTimer: NSObject, NSCoding{
    var delegate: PomoflowTimerDelegate?
    var workTimer: Timer?
    var pomodoroOrBreakTimer: Timer?
    
    var workLength: Int
    var pomodoroLength: Int
    var breakLength: Int
    
    var onBreak = false
    
    var workLengthRemaining = 0
    var pomodoroOrBreakLengthRemaining = 0
    
    required convenience init(coder decoder: NSCoder){
        let workLength = decoder.decodeInteger(forKey: "workLength")
        let pomdoroLength = decoder.decodeInteger(forKey: "pomodoroLength")
        let breakLength = decoder.decodeInteger(forKey: "breakLength")
        
        self.init(workLength: workLength, pomodoroLength: pomdoroLength, breakLength: breakLength)
    }
    
    init(workLength: Int, pomodoroLength: Int, breakLength: Int){
        self.workLength = workLength
        self.pomodoroLength = pomodoroLength
        self.breakLength = breakLength
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(workLength, forKey: "workLength")
        aCoder.encode(pomodoroLength, forKey: "pomodoroLength")
        aCoder.encode(breakLength, forKey: "breakLength")
    }
    
    func start(){
        delegate?.updateRemaingTime(workTime: workLength, pomodoroOrBreakTime: pomodoroLength)
        
        startLongTimer(length: workLength)
        startShortTimer(length: pomodoroLength)
    }
    
    func startBreak(){
        startShortTimer(length: breakLength)
    }
    
    func startPomodoroSession(){
        startShortTimer(length: pomodoroLength)
    }
    
    func skip(){
        onBreak = !onBreak
        pomodoroOrBreakLengthRemaining = 0
        pomodoroOrBreakTimer?.invalidate()
        delegate?.updateRemaingTime(workTime: workLengthRemaining, pomodoroOrBreakTime: pomodoroOrBreakLengthRemaining)
    }
    
    func startNext(){
        if onBreak {
            startShortTimer(length: breakLength)
        } else {
            startShortTimer(length: pomodoroLength)
        }
    }
    
    private func startLongTimer(length: Int){
        workLengthRemaining = length
        
        guard let delegate = self.delegate else {
            print("Timer has no delegate!")
            return
        }
        
        workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.workLengthRemaining -= 1
            
            if self.workLengthRemaining >= 0 {
                delegate.updateRemaingTime(workTime: self.workLengthRemaining, pomodoroOrBreakTime: self.pomodoroOrBreakLengthRemaining)
            }
            
            if self.workLengthRemaining == 0 {
                delegate.workFinished()
                timer.invalidate()
                self.pomodoroOrBreakTimer?.invalidate()
                self.delegate = nil
            }
        }
    }
    
    private func startShortTimer(length: Int){
        pomodoroOrBreakLengthRemaining = length
        
        guard let delegate = self.delegate else {
            print("Timer has no delegate!")
            return
        }
        
        pomodoroOrBreakTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
            self.pomodoroOrBreakLengthRemaining -= 1
            
            delegate.updateRemaingTime(workTime: self.workLengthRemaining, pomodoroOrBreakTime: self.pomodoroOrBreakLengthRemaining)
            
            if self.pomodoroOrBreakLengthRemaining == 0 {
                if self.onBreak{
                    delegate.breakFinished()
                }else{
                    delegate.pomodoroFinished()
                }
                
                timer.invalidate()
                self.onBreak = !self.onBreak
            }
        }
    }
    
    func pause(){
        pomodoroOrBreakTimer?.invalidate()
        workTimer?.invalidate()
    }
    
    func unPause(){
        startLongTimer(length: workLengthRemaining)
        startShortTimer(length: pomodoroOrBreakLengthRemaining)
    }
    
    func stop(){
        delegate = nil
        workTimer?.invalidate()
        pomodoroOrBreakTimer?.invalidate()
    }
    
    static func returnAsHours(min: Int) -> String{
        var asHours = "\(min / 60):"
        if min % 60 > 9 {
            asHours += "\(min % 60)"
        }else{
            asHours += "0\(min % 60)"
        }
        return asHours + "h"
    }
}
