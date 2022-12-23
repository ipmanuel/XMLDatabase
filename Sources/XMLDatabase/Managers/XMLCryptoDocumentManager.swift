//
//  XMLCryptoDocumentManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 27.01.21.
//


import Foundation
#if canImport(FoundationXML)
    import FoundationXML
#endif

public class XMLCryptoDocumentManager: XMLDocumentManager {


    // MARK: - Init

    @available(*, unavailable)
    public override init(at url: URL, fileDataManager: FileDataManager?) throws {
        try super.init(at: url, fileDataManager: fileDataManager)
    }

    public init(at url: URL, cryptoManager: CryptoManager) throws {
        let fileDataManager = try FileCryptoDataManager(at: url, cryptoManager: cryptoManager)
        try super.init(at: url, fileDataManager: fileDataManager)
    }
    
    /// init xml document at some url
    public convenience init(at url: URL, with container: XMLDocumentContainer,
        cryptoManager: CryptoManager) throws {
        try FileCryptoDataManager.createFile(at: url, withData: container.export(), cryptoManager: cryptoManager)
        try self.init(at: url, cryptoManager: cryptoManager)
    }
}
