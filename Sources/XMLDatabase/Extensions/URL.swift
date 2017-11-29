//
//  URL.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 25.11.17.
//

import Foundation

enum URLError: Error {
    case fileDoesNotExist(name: String, path: String)
    case fileWithNewFilenameExistsAlready(oldName: String, newName: String, in: String)
}


extension URL {
    /// rename the file specified in the url
    mutating func rename(newName: String) throws {
        // save old name
        let oldName = self.lastPathComponent
        
        // file should exists
        guard FileManager.default.fileExists(atPath: self.path) else {
            throw URLError.fileDoesNotExist(name: oldName, path: self.deletingPathExtension().path)
        }
        
        // there should not exists a file with the new name
        let newUrl = self.deletingLastPathComponent().appendingPathComponent(newName)
        guard !FileManager.default.fileExists(atPath: newUrl.path) else {
            throw URLError.fileWithNewFilenameExistsAlready(oldName: oldName, newName: newName, in: self.deletingLastPathComponent().path)
        }
        
        // change name
        var resourceValues = URLResourceValues()
        resourceValues.name = newName
        try self.setResourceValues(resourceValues)
        self.deleteLastPathComponent()
        self.appendPathComponent(newName)
    }
    
    static func removeFileIfExists(file url: URL) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("File could not removed \(url.path): \(error)")
        }
    }
}
