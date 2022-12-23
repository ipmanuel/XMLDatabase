//
//  XMLDocumentManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 29.12.20.
//


import Foundation
#if canImport(FoundationXML)
	import FoundationXML
#endif
import SWXMLHash

/// load and save a xml document with mutual exclusion
open class XMLDocumentManager {


    // MARK: - Properties

    public var url: URL {
        return fileDataManager.url
    }
    public var filename: String {
        return fileDataManager.filename
    }
    public var isLocked: Bool {
        return fileDataManager.isLocked
    }
    public let fileDataManager: FileDataManager
    var container: XMLDocumentContainer
    private let mutex = Mutex()


    // MARK: - Init


    /// init existing xml document from some url and lock it
    public init(at url: URL, fileDataManager: FileDataManager? = nil) throws {
        if fileDataManager != nil {
            self.fileDataManager = fileDataManager!
        } else {
            self.fileDataManager = try FileDataManager(at: url)
        }
        container = try XMLDocumentContainer(objectName: "Dummy", objectNamePlural: "Dummies")
        container = try loadAndLock(fileDataManager: self.fileDataManager)
    }

    /// init xml document at some url
    public convenience init(at url: URL, with container: XMLDocumentContainer) throws {
        try FileDataManager.createFile(at: url, withData: container.export())
        try self.init(at: url)
    }

    /// autounlock
    deinit {
        try? unlock()
    }


    // MARK: - Public Methods

    public func save() throws {
        try save(fileDataManager: fileDataManager, data: container.export())
    }
    
    open func saveAndUnlock(container: XMLDocumentContainer) throws {
        try fileDataManager.saveAndUnlock(data: container.export())
    }

    public func unlock() throws {
        try fileDataManager.unlock()   
    }
    
    public func workWithContainer(body: (XMLDocumentContainer) throws -> ()) throws {
        try mutex.withCriticalScope {
            try body(container)
        }
    }
    
    open func loadAndLock(fileDataManager: FileDataManager) throws -> XMLDocumentContainer {
        let loadedData = try fileDataManager.loadAndLock()
        let xmlString = String(decoding: loadedData, as: UTF8.self)

        return try XMLDocumentContainer(xmlString: xmlString)
    }
    
    open func save(fileDataManager: FileDataManager, data: Data) throws {
        try fileDataManager.save(data: data)
    }
}
