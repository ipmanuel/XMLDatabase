//
//  XMLDatabase.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 29.11.17.
//

import Foundation

/// Protocol in which all XMLObjects should be in (located in url)
public protocol XMLDatabase {
    init (url: URL) throws
}

/// Each `XMLDatabase` should unlock all XML files if they are locked
extension XMLDatabase {
    
    /// unlock a XML file by remove first character ("_")
    public static func unlockIfXMLFileExists(url: inout URL) throws {
        var filename = url.lastPathComponent
        if FileManager.default.fileExists(atPath: url.path) {
            filename.remove(at: filename.startIndex)
            try url.rename(newName: filename)
        }
    }
}
