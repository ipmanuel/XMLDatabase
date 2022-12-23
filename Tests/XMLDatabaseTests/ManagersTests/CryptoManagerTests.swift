//
//  CryptoManagerTests.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 14.12.20.
//


import XCTest
@testable import XMLDatabase

final class CryptoManagerTests: XCTestCase {
    
    
    // MARK: - Init tests

    func testInitWithEmptyKey() throws {
        let manager = CryptoManager(keyBase64EncodedString: "")
        XCTAssertNil(manager)
    }

    func testInitWithExistingKey() throws {
        let key1 = CryptoManager.generateKeyBase64EncodedString()

        guard CryptoManager(keyBase64EncodedString: key1) != nil else {
            XCTFail("cryptoManager is nil")
            return
        }
    }
    
    
    // MARK: - Method `encrypt(input:)` and `decrypt(input:)` tests

    func testEncryptDecryptWithCorrectKey() throws {
        let manager = CryptoManager()
        let testString = "Hello World!"
        let encryptedData = try manager.encrypt(input: testString.uint8)
        let decryptedData = try manager.decrypt(encryptedData: encryptedData)
        let decryptedString = String(decoding: decryptedData, as: UTF8.self)

        XCTAssertEqual(decryptedString, testString)
    }

    func testEncryptDecryptWithWrongKey() throws {
        // encrypt test string
        let manager = CryptoManager()
        let testString = "Hello World!"
        let encryptedData = try manager.encrypt(input: testString.byteArray)

        // decrypt encrypted data with another key
        let manager2 = CryptoManager()
        var decryptedData: Data?

        XCTAssertThrowsError(decryptedData = try manager2.decrypt(encryptedData: encryptedData)) { error in
            guard case CryptoManagerError.decryptionFailed(_) = error else {
                return XCTFail("\(error)")
            }
        }
        XCTAssertNil(decryptedData)
    }
    
    
    // MARK: - Method `generateKeyBase64EncodedString()` tests
    
    func testGenerateKeyBase64EncodedString() throws {
        let generatedKey = CryptoManager.generateKeyBase64EncodedString()
        guard CryptoManager(keyBase64EncodedString: generatedKey) != nil else {
            XCTFail("Failed initalizing CryptoManager")
            return
        }
        
        let generatedKey2 = CryptoManager.generateKeyBase64EncodedString()
        XCTAssertNotEqual(generatedKey, generatedKey2)
    }
}

extension CryptoManagerTests {
    static var allTests = [
        ("testInitWithEmptyKey", testInitWithEmptyKey),
        ("testInitWithExistingKey", testInitWithExistingKey),
        ("testEncryptDecryptWithCorrectKey", testEncryptDecryptWithCorrectKey),
        ("testEncryptDecryptWithWrongKey", testEncryptDecryptWithWrongKey),
        ("testGenerateKeyBase64EncodedString", testGenerateKeyBase64EncodedString)
    ]
}
