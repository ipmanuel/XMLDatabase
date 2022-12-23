//
//  FileCryptDataManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 20.02.22.
//


import Foundation
#if canImport(FoundationXML)
    import FoundationXML
#endif

public class FileCryptoDataManager: FileDataManager {

    
    // MARK: - Properties
    
    private let cryptoManager: CryptoManager
    
    
    // MARK: - Init
    
    @available(*, unavailable)
    override init(at url: URL) throws {
        cryptoManager = CryptoManager()
        try super.init(at: url)
    }
    
    public init(at url: URL, cryptoManager: CryptoManager) throws {
        self.cryptoManager = cryptoManager
        try super.init(at: url)
    }


    // MARK: - Public Methods
    
    public func save(encryptedData: Data) throws {
        try super.save(data: encryptedData)
    }
    
    public override func save(data: Data) throws {
        let encryptedData = try cryptoManager.encrypt(input: data)
        try save(encryptedData: encryptedData)
    }

    public override func load() throws -> Data {
        let loadedEncrypteddData = try super.load()
        let decryptedData = try cryptoManager.decrypt(encryptedData: loadedEncrypteddData)
        
        return decryptedData
    }
    
    
    // MARK: - Static Methods
    
    public static func createFile(at url: URL, withData data: Data, cryptoManager: CryptoManager) throws {
        let encryptedData = try cryptoManager.encrypt(input: data)
        try FileDataManager.createFile(at: url, withData: encryptedData)
    }
}
