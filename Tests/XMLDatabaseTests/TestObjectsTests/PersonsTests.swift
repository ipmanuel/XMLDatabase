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
    
    
    // MARK: - PersonsTests
    
    func testConstraintOnePersonExists() {
        personsXMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons></persons>"
        createUnlockedXMLFile()
        
        var persons: Persons?
        XCTAssertNoThrow(persons = try Persons(xmlFileURL: personsUnlockedXMLFilePath!))
        XCTAssertThrowsError(try persons?.save()) { error in
            guard case PersonsError.onePersonDoesNotExist() = error else {
                return XCTFail("\(error)")
            }
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
        ("testConstraintOnePersonExists", testConstraintOnePersonExists)
    ]
}