//
//  DateTimeExtensions.swift
//  Pods
//
//  Created by Jordan Zucker on 8/5/16.
//
//

import Foundation

class CreationDateFormatter: DateFormatter {
    
    override init() {
        super.init()
        self.dateStyle = .long
        self.timeStyle = .long
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let sharedInstance =  CreationDateFormatter()
}

extension Date {
    func creationTimeStampString() -> String {
        let formatter = CreationDateFormatter.sharedInstance
        return formatter.string(from: self)
    }
}
