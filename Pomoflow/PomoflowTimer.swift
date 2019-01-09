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
        workLengthRemaining = workLength
        pomodoroOrBreakLengthRemaining = pomodoroLength
        
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
        
        var onBreak = false
        
        pomodoroOrBreakTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true){ timer in
            self.pomodoroOrBreakLengthRemaining -= 1
            
            if self.pomodoroOrBreakLengthRemaining >= 0{
                delegate.updateRemaingTime(workTime: self.workLengthRemaining, pomodoroOrBreakTime: self.pomodoroOrBreakLengthRemaining)
            }
            
            if self.pomodoroOrBreakLengthRemaining == 0 {
                if onBreak{
                    self.pomodoroOrBreakLengthRemaining = self.pomodoroLength
                    delegate.breakFinished()
                }else{
                    self.pomodoroOrBreakLengthRemaining = self.breakLength
                    delegate.pomodoroFinished()
                }
                
                onBreak = !onBreak
            }
        }
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
