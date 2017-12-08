//
//  URL.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 25.11.17.
//

import Foundation

extension URL {
    /// rename the file specified in the url
    public mutating func rename(newName: String) throws {
        // save old name
        let oldName = self.lastPathComponent
        
        // file should exists
        guard FileManager.default.fileExists(atPath: self.path) else {
            throw URLError.fileDoesNotExist(at: self)
        }
        
        // there should not exists a file with the new name
        let newUrl = self.deletingLastPathComponent().appendingPathComponent(newName)
        guard !FileManager.default.fileExists(atPath: newUrl.path) else {
            throw URLError.fileWithNewFilenameExistsAlready(oldName: oldName, at: self.deletingLastPathComponent())
        }
        
        // change name
        var resourceValues = URLResourceValues()
        resourceValues.name = newName
        try self.setResourceValues(resourceValues)
        self.deleteLastPathComponent()
        self.appendPathComponent(newName)
    }
}
