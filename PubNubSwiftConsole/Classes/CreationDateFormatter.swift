//
//  CreationDateFormatter.swift
//  Pods
//
//  Created by Keith Martin on 8/4/16.
//
//

import Foundation

class CreationDateFormatter: NSDateFormatter {
    
    override init() {
        super.init()
        self.dateStyle = .LongStyle
        self.timeStyle = .LongStyle
        self.timeZone = NSTimeZone.localTimeZone()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let sharedInstance =  CreationDateFormatter()
}
