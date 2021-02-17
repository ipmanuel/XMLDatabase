/*
import XCTest
@testable import XMLDatabase

class PersonsTests: XCTestCase {
    
    // MARK: - Properties
    
    private var basePath: URL?
    private var personsXMLContent: String?
    private var personsLockedXMLFilePath: URL?
    private var personsUnlockedXMLFilePath: URL?
    
    
    // MARK: - Init
    
    override func setUp() {
        super.setUp()
        
        // basePath
        basePath = Bundle.init(for: PersonsTests.self).resourceURL!
        
        // persons locked and unlocked xml files
        personsXMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><relation>me</relation><firstName>Manuel</firstName><lastName>Pauls</lastName></person></persons>"
        personsLockedXMLFilePath = basePath!.appendingPathComponent("_Persons.xml")
        personsUnlockedXMLFilePath = basePath!.appendingPathComponent("Persons.xml")
    }
    
    override func tearDown() {
        removeFileIfExists(file: personsLockedXMLFilePath!)
        removeFileIfExists(file: personsUnlockedXMLFilePath!)
        
        super.tearDown()
    }
    
    
    // MARK: - Init tests
    
    func testInitConstraintOnePersonExists() {
        personsXMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons></persons>"
        createUnlockedXMLFile()
        
        XCTAssertThrowsError(try Persons(xmlFileURL: personsUnlockedXMLFilePath!)) { error in
            guard case PersonsError.onePersonDoesNotExist() = error else {
                return XCTFail("\(error)")
            }
        }
    }
    
    
    // MARK: - Method `delete()` tests
    
    func testSaveConstraintOnePersonExists() {
        createUnlockedXMLFile()
        
        var persons: Persons?
        XCTAssertNoThrow(persons = try Persons(xmlFileURL: personsUnlockedXMLFilePath!))
        XCTAssertThrowsError(try persons?.deleteObject(id: 1)) { error in
            XCTAssertEqual(error as! PersonsError, PersonsError.atLeastOnePersonShouldExist())
        }
    }
    
    
    // MARK: - Private Methods
    
    private func createUnlockedXMLFile() {
        XCTAssertNoThrow(try personsXMLContent!.write(to: personsUnlockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8))
        XCTAssert(FileManager.default.fileExists(atPath: personsUnlockedXMLFilePath!.path))
    }
}

extension PersonsTests {
    static var allTests = [
        ("testInitConstraintOnePersonExists", testInitConstraintOnePersonExists),
        ("testSaveConstraintOnePersonExists", testSaveConstraintOnePersonExists)
    ]
}
*/