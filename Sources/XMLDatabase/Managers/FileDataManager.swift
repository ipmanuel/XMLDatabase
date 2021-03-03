//
//  FileDataManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 28.12.20.
//


import Foundation
import FoundationXML

/// Handle mutual exclusion for reading and write a file
public class FileDataManager {


    // MARK: - Public Properties

    public var url: URL {
        return isLocked ? lockedFileURL : unlockedFileURL
    }

    public var isLocked: Bool {
        return isLockedMutable
    }

    private static let mutex = Mutex()


    // MARK: - Private Properties

    private var isLockedMutable: Bool

    public var filename: String {
        return unlockedFilename
    }
    
    let unlockedFileURL: URL
    
    let lockedFileURL: URL

    let unlockedFilename: String
    
    let lockedFilename: String


    // MARK: - Init
    
    // force Unlock is untested!
    private init(at url: URL, hasToCheckFiles: Bool, forceUnlock: Bool = false) throws {
        unlockedFileURL = URL(fileURLWithPath: url.path)
        isLockedMutable = false

        unlockedFilename = url.lastPathComponent
        lockedFilename = "_\(unlockedFilename)"
        lockedFileURL = URL(fileURLWithPath: url.deletingLastPathComponent().path).appendingPathComponent(lockedFilename)

        if forceUnlock {
            try? self.unlock()
        }

        guard !isLocked else {
            throw FileDataManagerError.fileIsAlreadyLocked(at: lockedFileURL)
        }

        // check the existence of the unlocked and the locked xml file
        if hasToCheckFiles {
            try checkFiles()
        }
    }

    public convenience init(at url: URL, forceUnlock: Bool = false) throws {
        try self.init(at: url, hasToCheckFiles: true, forceUnlock: forceUnlock)
    }

    public convenience init(at url: URL, withData data: Data) throws {
        try self.init(at: url, hasToCheckFiles: false)
        
        // write a small sized file to set short critical scope
        let emptyData = "".data(using: .utf8)!
        try FileDataManager.mutex.withCriticalScope {
            guard !checkLockedFileExists() && !checkUnlockedFileExists() else {
                throw FileDataManagerError.fileExistsAlready(at: url)
            }
            try emptyData.write(to: url)
        }

        // write acutal data
        do {
            try data.write(to: url)
        } catch {
            try? Foundation.FileManager.default.removeItem(atPath: url.path)
            throw FileDataManagerError.writeFileDataFailed(at: url, error: error)
        }
    }

    deinit {
        try? unlock()
    }


    // MARK: - Public Methods

    public func saveAndUnlock(data: Data) throws {
        guard isLocked else {
            throw FileDataManagerError.fileIsNotLocked(at: url)
        }
        try checkFiles()
        try save(data: data)
        try unlock()
    }

    public func loadAndLock() throws -> Data {
        guard isLocked == false else {
            throw FileDataManagerError.fileIsAlreadyLocked(at: url)
        }
        try lock()

        var data: Data

        do {
            data = try load()
        } catch {
            try unlock()
            throw error
        }

        return data
    }

    public func load() throws -> Data {
        return try Data(contentsOf: url)
    }


    // MARK: - Internal Methods

    func checkFiles() throws {
        if isLocked {
            guard checkLockedFileExists() else {
                throw FileDataManagerError.fileDoesNotExist(at: lockedFileURL)
            }
            guard !checkUnlockedFileExists() else {
                throw FileDataManagerError.unlockedAndLockedFileExists(unlockedAt: unlockedFileURL, lockedAt: lockedFileURL)
            }
        } else {
            guard checkUnlockedFileExists() else {
                throw FileDataManagerError.fileDoesNotExist(at: unlockedFileURL)
            }
            guard !checkLockedFileExists() else {
                throw FileDataManagerError.unlockedAndLockedFileExists(unlockedAt: unlockedFileURL, lockedAt: lockedFileURL)
            }
        }
    }

    func lock() throws {
        try FileDataManager.mutex.withCriticalScope {
            updateIsLockedMutable()
            try checkFiles()

            guard !isLocked else {
                throw FileDataManagerError.fileIsAlreadyLocked(at: lockedFileURL)
            }
            try Foundation.FileManager.default.moveItem(atPath: unlockedFileURL.path, toPath: lockedFileURL.path)
            isLockedMutable = true
        }
    }

    public func unlock() throws {
        try FileDataManager.mutex.withCriticalScope {
            updateIsLockedMutable()
            try checkFiles()
            guard isLocked else {
                throw FileDataManagerError.fileIsNotLocked(at: unlockedFileURL)
            }
            try Foundation.FileManager.default.moveItem(atPath: lockedFileURL.path, toPath: unlockedFileURL.path)
            isLockedMutable = false
        }
    }

    func save(data: Data) throws {
        try data.write(to: url)
    }

    func updateIsLockedMutable() {
        isLockedMutable = checkLockedFileExists()
    }

    func checkLockedFileExists() -> Bool {
        return Foundation.FileManager.default.fileExists(atPath: lockedFileURL.path)
    }

    func checkUnlockedFileExists() -> Bool {
        return Foundation.FileManager.default.fileExists(atPath: unlockedFileURL.path)
    }
}
