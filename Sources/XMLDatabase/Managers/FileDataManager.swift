//
//  FileDataManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 28.12.20.
//


import Foundation
#if canImport(FoundationXML)
	import FoundationXML
#endif

/// Handle mutual exclusion for reading and write a file
public class FileDataManager {


    // MARK: - Public Properties

    public var url: URL {
        return isLocked ? lockedFileURL : unlockedFileURL
    }
    
    public var filename: String {
        return unlockedFileURL.lastPathComponent
    }

    public var isLocked: Bool {
        return isLockedMutable
    }

    private static let mutex = Mutex()


    // MARK: - Private Properties

    private var isLockedMutable: Bool
    
    let unlockedFileURL: URL
    
    let lockedFileURL: URL


    // MARK: - Init
    
    /// init existing file
    public init(at url: URL) throws {
        unlockedFileURL = URL(fileURLWithPath: url.path)
        lockedFileURL = FileDataManager.generateLockedFileURL(of: unlockedFileURL)
        
        isLockedMutable = false
        updateIsLockedMutable()
        
        // check the existence of the unlocked and the locked file
        try checkFiles()
        
        guard !isLocked else {
            throw FileDataManagerError.fileIsAlreadyLocked(at: lockedFileURL)
        }
    }

    deinit {
        try? unlock()
    }


    // MARK: - Public Methods
    
    public func save(data: Data) throws {
        guard isLocked else {
            throw FileDataManagerError.fileIsNotLocked(at: url)
        }
        try data.write(to: url)
    }

    public func saveAndUnlock(data: Data) throws {
        guard isLocked else {
            throw FileDataManagerError.fileIsNotLocked(at: url)
        }
        try checkFiles()
        try save(data: data)
        try unlock()
    }

    public func loadAndLock() throws -> Data {
        guard !isLocked else {
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

    func updateIsLockedMutable() {
        isLockedMutable = checkLockedFileExists()
    }

    func checkLockedFileExists() -> Bool {
        return FileDataManager.checkFileExists(at: lockedFileURL)
    }

    func checkUnlockedFileExists() -> Bool {
        return FileDataManager.checkFileExists(at: unlockedFileURL)
    }
    
    
    // MARK: - Static Methods
    
    public static func createFile(at url: URL, withData data: Data) throws {
        let unlockedFileURL = URL(fileURLWithPath: url.path)
        let lockedFileURL = generateLockedFileURL(of: url)
        
        var fileExists = checkFileExists(at: unlockedFileURL)
        fileExists = fileExists || checkFileExists(at: lockedFileURL);
        
        guard !fileExists else {
            throw FileDataManagerError.fileExistsAlready(at: url)
        }
        
        // create file
        do {
            try data.write(to: url)
        } catch {
            try? Foundation.FileManager.default.removeItem(atPath: url.path)
            throw FileDataManagerError.writeFileDataFailed(at: url, error: error)
        }
    }
    
    public static func checkFileExists(at url: URL) -> Bool {
        return Foundation.FileManager.default.fileExists(atPath: url.path)
    }
    
    public static func generateLockedFileURL(of url: URL) -> URL {
        let unlockedFilename = url.lastPathComponent
        let lockedFilename = "_\(unlockedFilename)"
        let lockedFilePath = url.deletingLastPathComponent().path
        let lockedFileURL = URL(fileURLWithPath: lockedFilePath).appendingPathComponent(lockedFilename)
        
        return lockedFileURL
    }
}
