//
//  XMLDocumentManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 29.12.20.
//


import Foundation
import FoundationXML
import SWXMLHash

/// Handle mutual exclusion for reading and write a file
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


    // MARK: - Init


    /// init existing xml document from some url
	public init(at url: URL) throws {
		fileDataManager = try FileDataManager(at: url)
	}

    /// init xml document at some url
    public convenience init(at url: URL, with container: XMLDocumentContainer) throws {
        try FileDataManager(at: url, withData: container.export())
        try self.init(at: url)
    }

    /// autounlock
    deinit {
        try? unlock()
    }


    // MARK: - Public Methods

	open func loadAndLock() throws -> XMLDocumentContainer {
        let loadedData = try self.fileDataManager.loadAndLock()
        let xmlString = String(decoding: loadedData, as: UTF8.self)

        return try XMLDocumentContainer(xmlString: xmlString)
	}

    open func load() throws -> XMLDocumentContainer {
        let loadedData = try self.fileDataManager.load()
        let xmlString = String(decoding: loadedData, as: UTF8.self)

        return try XMLDocumentContainer(xmlString: xmlString)
    }

    open func saveAndUnlock(container: XMLDocumentContainer) throws {
        try fileDataManager.saveAndUnlock(data: try container.export())
    }

    public func unlock() throws {
        try fileDataManager.unlock()   
    }
}