//
//  PomoflowTimer.swift
//  Pomoflow
//
//  Created by Jens Amund on 12/10/2018.
//  Copyright © 2018 Jakkaps. All rights reserved.
//

import Cocoa

class PomoflowTimer: NSObject {
    let pomodoroLength : Int
    let workLength : Int
    
    var timeRemainingPomodoro : Int
    var timeRemainingWork : Int
    
    var closureForBreakSession : () -> Void
    
    var timer : Timer?
    
    init(pomodoroLength: Int, workLength: Int, closureForBreakSession: @escaping () -> Void) {
        self.pomodoroLength = pomodoroLength
        self.workLength = workLength
        
        self.timeRemainingWork = workLength
        self.timeRemainingPomodoro = pomodoroLength
        
        self.closureForBreakSession = closureForBreakSession
        
        super.init()
    }

    func start(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.timeRemainingPomodoro -= 1
            self.timeRemainingWork -= 1
            
            if self.timeRemainingPomodoro == 0 {
                self.closureForBreakSession()
            }
            
            if self.remainingTimeWork == 0 {
                
            }
            
        }
    }

}
