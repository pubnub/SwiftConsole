//
//  DateTimeExtensions.swift
//  Pods
//
//  Created by Jordan Zucker on 8/5/16.
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

extension NSDate {
    func creationTimeStampString() -> String {
        let formatter = CreationDateFormatter.sharedInstance
        return formatter.stringFromDate(self)
    }
}
