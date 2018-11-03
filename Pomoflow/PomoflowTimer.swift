//
//  PomoflowTimer.swift
//  Pomoflow
//
//  Created by Jens Amund on 25/10/2018.
//  Copyright © 2018 Jakkaps. All rights reserved.
//

import Foundation

class PomoflowTimer: NSObject, NSCoding{
    var workLength: Int
    var pomodoroLength: Int
    var breakLength: Int
    
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
    
    static func returnAsHours(min: Int) -> String{
        return "\(min / 60):\(min % 60)h"
    }
}
