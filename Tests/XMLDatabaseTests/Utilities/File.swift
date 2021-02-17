//
//  File.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 15.01.21.
//


import Foundation

func removeFileIfExists(file url: URL) {
    do {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    } catch {
        print("File could not removed at \(url.path): \(error)")
    }
}