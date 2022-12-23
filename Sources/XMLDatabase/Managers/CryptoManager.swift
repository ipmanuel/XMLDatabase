//
//  CryptoManager.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 14.12.20.
//

import Foundation
import Crypto

public final class CryptoManager {

    
    // MARK: - Properties

    private var key: SymmetricKey


    // MARK: - Init
    
    /// Init with new Key
    public init() {
        self.key = SymmetricKey(size: .bits256)
    }
    
    /// Init with an existing key
    public init(key: SymmetricKey) {
        self.key = key
    }

    /// Init with an existing key identified by a string
    public init? (keyBase64EncodedString: String) {
        guard keyBase64EncodedString != "" else {
            return nil
        }

        guard let data = Data(base64Encoded: keyBase64EncodedString) else {
            return nil
        }

        let key = SymmetricKey(data: data)
        guard CryptoManager.checkKey(key: key) else {
            return nil
        }
        
        self.key = key
    }
    

    // MARK: - Public methods

    public func encrypt(input: Data) throws -> Data {
        let byteArray = [UInt8](input)
        return try CryptoManager._encrypt(input: byteArray, key: self.key)
    }

    public func encrypt(input: [UInt8]) throws -> Data {
        return try CryptoManager._encrypt(input: input, key: self.key)
    }

    public func decrypt(encryptedData: Data) throws -> Data {
        var decyptedData: Data?

        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            decyptedData = try AES.GCM.open(sealedBox, using: self.key)
        } catch {
            throw CryptoManagerError.decryptionFailed(error: error)
        }
        guard decyptedData != nil else {
            throw CryptoManagerError.decryptionFailed(error: nil)
        }

        return decyptedData!
    }
    
    public static func generateKeyBase64EncodedString() -> String {
        let key = SymmetricKey(size: .bits256)
        return CryptoManager.getKeyBase64EncodedString(key: key)
    }

    
    // MARK: - Private methods

    private func getKeyBase64EncodedString() -> String {
        return CryptoManager.getKeyBase64EncodedString(key: self.key)
    }

    private static func checkKey(key: SymmetricKey) -> Bool {
        do {
            let _ = try _encrypt(input: "Test".uint8, key: key)
        } catch {
            return false
        }

        return true
    }

    private static func _encrypt(input: [UInt8], key: SymmetricKey) throws -> Data {
        var sealedBox: AES.GCM.SealedBox
        do {
            sealedBox = try AES.GCM.seal(input, using: key)
        } catch {
            throw CryptoManagerError.encryptionFailed(error: error)
        }
        guard let combined = sealedBox.combined else {
            throw CryptoManagerError.encryptionFailed(error: nil)
        }

        return combined
    }
    
    private static func getKeyBase64EncodedString(key: SymmetricKey) -> String {
        let keyBase64EncodedString = key.withUnsafeBytes {
            return Data(Array($0)).base64EncodedString()
        }
        
        return keyBase64EncodedString
    }
}

public enum CryptoManagerError: Error {
    case encryptionFailed(error: Error? = nil)
    case decryptionFailed(error: Error? = nil)
}
