import XCTest
@testable import XMLDatabase

class PersonsXMLDatabaseTests: XCTestCase {
    
    
    // MARK: - Properties
    
    private var baseURL: URL?
    private var personsXMLContent: String?
    private var personsLockedXMLFileURL: URL?
    private var personsUnlockedXMLFileURL: URL?
    
    
    // MARK: - Init
    
    override func setUp() {
        super.setUp()
        
        baseURL = Bundle.init(for: PersonsXMLDatabaseTests.self).resourceURL!
        personsXMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName><lastName>Pauls</lastName></person></persons>"
        personsLockedXMLFileURL = baseURL!.appendingPathComponent("_Persons.xml")
        personsUnlockedXMLFileURL = baseURL!.appendingPathComponent("Persons.xml")
    }
    
    override func tearDown() {
        removeFileIfExists(file: personsLockedXMLFileURL!)
        removeFileIfExists(file: personsUnlockedXMLFileURL!)
        
        super.tearDown()
    }
    
    
    // MARK: - Init tests
    
    func testXMLFileExists() {
        // create unlocked XML file
        XCTAssertNoThrow(try personsXMLContent!.write(to: personsUnlockedXMLFileURL!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssert(FileManager.default.fileExists(atPath: personsUnlockedXMLFileURL!.path))
        
        // create PersonsXMLDatabase
        XCTAssertNoThrow(try PersonsXMLDatabase(url: baseURL!))
    }
    
    func testXMLFileDoesNotExist() {
        XCTAssertThrowsError(try PersonsXMLDatabase(url: baseURL!)) { error in
            guard case XMLObjectsError.xmlFileDoesNotExist(_) = error else {
                return XCTFail("\(error)")
            }
        }
    }
}


extension PersonsXMLDatabaseTests {
    static var allTests = [
        ("testXMLFileExists", testXMLFileExists),
        ("testXMLFileDoesNotExist", testXMLFileDoesNotExist)
    ]
}
