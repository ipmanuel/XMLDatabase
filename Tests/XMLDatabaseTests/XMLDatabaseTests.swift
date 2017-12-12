import Foundation
import XCTest
@testable import XMLDatabase

class XMLDatabaseTests: XCTestCase {
    
    
    // MARK: - Properties
    
    private var basePath: URL?
    private var xmlContent: String?
    private var lockedXMLFilePath: URL?
    private var unlockedXMLFilePath: URL?
    
    
    // MARK: - Init
    
    override func setUp() {
        super.setUp()
        
        basePath = Bundle.init(for: XMLDatabaseTests.self).resourceURL!
        xmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName></person></persons>"
        lockedXMLFilePath = basePath!.appendingPathComponent("_Persons.xml")
        unlockedXMLFilePath = basePath!.appendingPathComponent("Persons.xml")
    }
    
    override func tearDown() {
        removeFileIfExists(file: lockedXMLFilePath!)
        removeFileIfExists(file: unlockedXMLFilePath!)
        
        super.tearDown()
    }
    
    
    // MARK: - Method `unlockIfXMLFileExists()` tests
    
    func testWithLockedFile() {
        XCTAssertNoThrow(try xmlContent!.write(to: lockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssertTrue(FileManager.default.fileExists(atPath: lockedXMLFilePath!.path))
        XCTAssertNoThrow(try PersonsXMLDatabase(url: basePath!))
    }
    
    func testWithUnlockedFile() {
        XCTAssertNoThrow(try xmlContent!.write(to: unlockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssertTrue(FileManager.default.fileExists(atPath: unlockedXMLFilePath!.path))
        XCTAssertNoThrow(try PersonsXMLDatabase(url: basePath!))
    }
}

extension XMLDatabaseTests {
    static var allTests = [
        ("testWithLockedFile", testWithLockedFile),
        ("testWithUnlockedFile", testWithUnlockedFile)
    ]
}
