//
//  XMLCryptoDocumentManagerTests.swift
//  XMLDatabase
//
//  Created by Manuel Pauls on 30.01.21.
//


import XCTest
@testable import XMLDatabase

final class XMLCryptoDocumentManagerTests: XCTestCase {

    var testFileURL: URL!
    var manager: XMLCryptoDocumentManager!
    var cryptoManager: CryptoManager!

    // It is called before every test method.
    override func setUp() {
        super.setUp()
        
        let baseURL = FileManager.default.temporaryDirectory

        testFileURL = baseURL.appendingPathComponent("DiaryEntries.xml.enc")
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: testFileURL.path))
        cryptoManager = CryptoManager()
    }

    // It is called after all test methods complete.
    override func tearDown() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: testFileURL.path))
    }
    
    
    // MARK: - Init tests
    
    func testInit() throws {
        try testInitWithContainer()
        XCTAssertNoThrow(try XMLCryptoDocumentManager(at: testFileURL, cryptoManager: cryptoManager))
    }
    
    func testInitWithContainer() throws {
        let container = try XMLDocumentContainer(objectName: "DiaryEntry", objectNamePlural: "DiaryEntries")

        XCTAssertNoThrow(try XMLCryptoDocumentManager(at: testFileURL, with: container, cryptoManager: cryptoManager))
        
    }
}

extension XMLCryptoDocumentManagerTests {
    static var allTests = [
        ("testInit", testInit),
        ("testInitWithContainer", testInitWithContainer)
    ]
}
