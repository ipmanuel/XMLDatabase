//
//  XMLDatabase.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 29.11.17.
//

import Foundation

public protocol XMLDatabase: class {
    init (url: URL) throws
}


extension XMLDatabase {
    public static func unlockIfXMLFileExists(url: inout URL) throws {
        var filename = url.lastPathComponent
        if FileManager.default.fileExists(atPath: url.path) {
            filename.remove(at: filename.startIndex)
            try url.rename(newName: filename)
        }
    }
}
