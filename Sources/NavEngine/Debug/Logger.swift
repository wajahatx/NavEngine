//
//  Logger.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import Foundation

protocol Logger {
    func log(_ value: String)
}

class DebugLog: Logger {
    func log(_ value: String) {
        print(value)
    }
}

class EmptyLog: Logger {
    func log(_ value: String) {
        
    }
}
