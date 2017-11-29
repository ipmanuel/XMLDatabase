import XCTest
@testable import XMLDatabase

class PersonsXMLDatabaseTests: XCTestCase {
    
    
    // MARK: init
    
    // basePath
    private var basePath: URL?
    
    // addresses XMLFiles
    private var addressesXMLFileContent: String?
    private var addressesLockedXMLFilePath: URL?
    private var addressesUnlockedXMLFilePath: URL?
    
    // persons locked XMLFile
    private var personsXMLContent: String?
    private var personsLockedXMLFilePath: URL?
    private var personsUnlockedXMLFilePath: URL?
    
    override func setUp() {
        super.setUp()
        
        // basePath
        basePath = Bundle.init(for: DiaryXMLDatabaseTests.self).resourceURL!
        
        // addresses locked and unlocked xml files
        addressesXMLFileContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><addresses><address id=\"1\"><city>Title</city><street>Name</street></address></addresses>"
        addressesLockedXMLFilePath = basePath!.appendingPathComponent("_Addresses.xml")
        addressesUnlockedXMLFilePath = basePath!.appendingPathComponent("Addresses.xml")
        
        // persons locked and unlocked xml files
        personsXMLContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><persons><person id=\"1\"><gender>male</gender><firstName>Manuel</firstName><lastName>Pauls</lastName></person></persons>"
        personsLockedXMLFilePath = basePath!.appendingPathComponent("_Persons.xml")
        personsUnlockedXMLFilePath = basePath!.appendingPathComponent("Persons.xml")
    }
    
    override func tearDown() {
        URL.removeFileIfExists(file: addressesLockedXMLFilePath!)
        URL.removeFileIfExists(file: addressesUnlockedXMLFilePath!)
        URL.removeFileIfExists(file: personsLockedXMLFilePath!)
        URL.removeFileIfExists(file: personsUnlockedXMLFilePath!)
        
        super.tearDown()
    }
    
    
    // MARK: unlock xml files
    
    func testDiaryXMLDatabaseWithLockedFiles() {
        do {
            try addressesXMLFileContent!.write(to: addressesLockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8)
            XCTAssert(FileManager.default.fileExists(atPath: addressesLockedXMLFilePath!.path))
            
            try personsXMLContent!.write(to: personsLockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8)
            XCTAssert(FileManager.default.fileExists(atPath: personsLockedXMLFilePath!.path))
            
            _ = try PersonsXMLDatabase(url: basePath!)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testDiaryXMLDatabaseWithAddressesLockedFile() {
        do {
            try addressesXMLFileContent!.write(to: addressesLockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8)
            XCTAssert(FileManager.default.fileExists(atPath: addressesLockedXMLFilePath!.path))
            
            try personsXMLContent!.write(to: personsUnlockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8)
            XCTAssert(FileManager.default.fileExists(atPath: personsUnlockedXMLFilePath!.path))
            
            _ = try PersonsXMLDatabase(url: basePath!)
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testDiaryXMLDatabaseWithPersonsLockedFile() {
        do {
            try addressesXMLFileContent!.write(to: addressesUnlockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8)
            XCTAssert(FileManager.default.fileExists(atPath: addressesUnlockedXMLFilePath!.path))
            
            try personsXMLContent!.write(to: personsLockedXMLFilePath!, atomically: true, encoding: String.Encoding.utf8)
            XCTAssert(FileManager.default.fileExists(atPath: personsLockedXMLFilePath!.path))
            
            _ = try PersonsXMLDatabase(url: basePath!)
            
        } catch {
            XCTFail("\(error)")
        }
    }

}

extension DiaryXMLDatabaseTests {
    static var allTests = [
        ("testDiaryXMLDatabaseWithLockedFiles", testDiaryXMLDatabaseWithLockedFiles),
        ("testDiaryXMLDatabaseWithAddressesLockedFile", testDiaryXMLDatabaseWithAddressesLockedFile),
        ("testDiaryXMLDatabaseWithPersonsLockedFile", testDiaryXMLDatabaseWithPersonsLockedFile)
        ]
}
